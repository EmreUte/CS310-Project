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
  int _currentStep = 0;
  late Timer _timer;
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
    // Cancel the timer if it's running
    if (_timer.isActive) {
      _timer.cancel();
    }

    // Show dialog after a short delay to ensure the context is available
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
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to profile page
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

// Modify _startProgressAnimation to navigate to ride progress when complete
  void _startProgressAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentStep < steps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        _timer.cancel(); // Stop when finished

        // Navigate to the appropriate ride progress screen
        if (_userType == 'Driver') {
          Navigator.pushNamed(context, '/ride_progress_driver');
        } else if (_userType == 'Passenger') {
          Navigator.pushNamed(context, '/ride_progress_passenger');
        } else {
          Navigator.pop(context); // Fallback if user type is unknown
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
          onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
                      // Cancel logic & return to the previous screen
                      _timer.cancel(); // Stop animation if user cancels
                      Navigator.pop(context);
                    },
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
