import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../matching_calc/matching_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/ride_session_service.dart'; // NEW
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';



class FindingRideScreen extends StatefulWidget {
  @override
  State<FindingRideScreen> createState() => _FindingRideScreenState();
}

class _FindingRideScreenState extends State<FindingRideScreen> {
  StreamSubscription<DocumentSnapshot>? _sessionListener;
  int _currentStep = 0;
  Timer? _timer;
  bool _matchFound = false;
  String _userType = '';

  final List<String> steps = [
    "Searching for a Ride",
    "Matching Driver Found",
    "Driver is on the way",
    "Driver is close by",
    "Driver has arrived",
  ];

  @override
  void initState() {
    super.initState();
    _getUserTypeAndStartMatching();
  }
  Future<void> _cancelAndResetSession() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _userType.isNotEmpty) {
      final isPassenger = _userType == 'Passenger';
      final passengerId = isPassenger ? currentUser.uid : await _getMatchedPassengerId();
      final driverId = isPassenger ? await _getMatchedDriverId() : currentUser.uid;

      if (passengerId != null && driverId != null) {
        final session = RideSessionService(passengerId: passengerId, driverId: driverId);
        await session.resetUserReadyStates();
      }
    }

    _timer?.cancel();
    if (mounted) Navigator.pop(context);
  }


  Future<String?> _getMatchedPassengerId() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return null;
    final sessions = await FirebaseFirestore.instance
        .collection('ride_sessions')
        .where('driverId', isEqualTo: currentUid)
        .get();
    return sessions.docs.isNotEmpty ? sessions.docs.first['passengerId'] : null;
  }

  Future<String?> _getMatchedDriverId() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return null;
    final sessions = await FirebaseFirestore.instance
        .collection('ride_sessions')
        .where('passengerId', isEqualTo: currentUid)
        .get();
    return sessions.docs.isNotEmpty ? sessions.docs.first['driverId'] : null;
  }

  Future<void> _getUserTypeAndStartMatching() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showNoMatchFoundDialog();
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        setState(() {
          _userType = userData['userType'] ?? '';
        });

        // Start the matching process
        _runMatchingAlgorithm(currentUser.uid);
      } else {
        _showNoMatchFoundDialog();
      }
    } catch (e) {
      print('Error getting user type: $e');
      _showNoMatchFoundDialog();
    }
  }

  Future<void> _runMatchingAlgorithm(String userId) async {
    try {
      final timeout = Duration(seconds: 10);
      final pollingInterval = Duration(seconds: 1);
      int waited = 0;

      while (waited < timeout.inSeconds) {
        final matches = await findBestMatches();

        for (var match in matches) {
          final isMatch = (_userType == 'Driver' && match.driver.id == userId) ||
              (_userType == 'Passenger' && match.passenger.id == userId);

          if (isMatch) {
            final session = RideSessionService(
              passengerId: match.passenger.id,
              driverId: match.driver.id,
            );

            // ✅ Check if there's a saved destination from tap before match
            final prefs = await SharedPreferences.getInstance();
            final lat = prefs.getDouble('pending_destination_lat');
            final lng = prefs.getDouble('pending_destination_lng');

            if (lat != null && lng != null) {
              await session.setDestination(LatLng(lat, lng));
              await prefs.remove('pending_destination_lat');
              await prefs.remove('pending_destination_lng');
            }

            // ✅ Mark user as ready
            await session.setUserReady(_userType);

            // ✅ Check if both are ready
            final isReady = await session.isBothReady();
            if (isReady) {
              _startProgressAnimation();
              return;
            }
          }
        }

        await Future.delayed(pollingInterval);
        waited += 1;
      }

      _showNoMatchFoundDialog();
    } catch (e) {
      print('Error in matching algorithm: $e');
      _showNoMatchFoundDialog();
    }
  }



  void _showNoMatchFoundDialog() {
    // Only cancel if _timer has been initialized
    if (mounted && (_timer?.isActive == true)) {
      _timer?.cancel();
    }

    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('No Match Found'),
            content: const Text('Sorry, we couldn\'t find a suitable match for you at this time. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog first
                  await _cancelAndResetSession(); // Then pop the page with state reset
                },

                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }
  void _stopAnimationAndShowNoMatch() {
    _timer?.cancel();
    _sessionListener?.cancel();

    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('No Match Found'),
            content: const Text('One of the parties canceled. Please try again.'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  await _cancelAndResetSession(); // Pop page and reset state
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }


  void _startProgressAnimation() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get session ID
    final isPassenger = _userType == 'Passenger';
    final sessionIdFuture = isPassenger ? _getMatchedDriverId() : _getMatchedPassengerId();

    sessionIdFuture.then((otherUserId) {
      if (otherUserId == null) return;
      final passengerId = isPassenger ? currentUser.uid : otherUserId;
      final driverId = isPassenger ? otherUserId : currentUser.uid;
      final sessionId = 'session_${passengerId}_$driverId';

      // Setup listener
      _sessionListener = FirebaseFirestore.instance
          .collection('ride_sessions')
          .doc(sessionId)
          .snapshots()
          .listen((snapshot) {
        final data = snapshot.data();
        if (data == null) return;

        final passengerReady = data['passengerReady'] == true;
        final driverReady = data['driverReady'] == true;

        if (!passengerReady || !driverReady) {
          _stopAnimationAndShowNoMatch();
        }
      });

      // Start animation
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_currentStep < steps.length - 1) {
          setState(() => _currentStep++);
        } else {
          _timer?.cancel();
          _sessionListener?.cancel();

          // Navigate to the appropriate screen
          if (_userType == 'Driver') {
            Navigator.pushNamed(context, '/ride_progress_driver');
          } else if (_userType == 'Passenger') {
            Navigator.pushNamed(context, '/ride_progress_passenger');
          } else {
            Navigator.pop(context);
          }
        }
      });
    });
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getStepColor(int index) {
    if (index == _currentStep) {
      return Colors.lightGreenAccent;
    } else if (index < _currentStep) {
      return Colors.lightBlue.shade200;
    } else {
      return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: _cancelAndResetSession,

        ),
        title: Text(
          "Find Your Ride",
          style: kAppBarText,
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.10),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              separatorBuilder: (_, __) => Column(
                children: const [
                  Icon(Icons.arrow_downward, size: 30),
                  SizedBox(height: 8),
                ],
              ),
              itemBuilder: (context, index) {
                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: _getStepColor(index),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      steps[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.15,
              child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      padding: Dimen.buttonPadding,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
              ),
            ),
                onPressed: _cancelAndResetSession,

                child: Center(
                      child: Text(
                              'Cancel',
                              style: kButtonText,
                      ),
                    ),
                  ),
                ),
              ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.10),
        ],
      ),
    );
  }
}
