import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../maps/road_trip_map.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../digital_payments/add_new_card.dart';
import 'package:cs310_project/services/database.dart';



class RideProgressPassenger extends StatefulWidget {
  @override
  _RideProgressPassengerState createState() => _RideProgressPassengerState();
}

class _RideProgressPassengerState extends State<RideProgressPassenger> {

  bool paymentSuccess = false;
  bool isLoading = true;
  bool hasCard = false;
  bool driverEndedRide = false;

  String startLocation = "Loading...";
  String endLocation = "Loading...";
  String estimatedTime = "Calculating...";
  String amount = "Calculating...";

  String? matchedDriverId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _findMatchedDriver();
    await _loadTripData();
    await _checkPaymentMethod();
    _pollForDriverEnd();
  }

  Future<void> _findMatchedDriver() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final sessions = await FirebaseFirestore.instance
        .collection('ride_sessions')
        .where('passengerId', isEqualTo: currentUid)
        .get();

    if (sessions.docs.isNotEmpty) {
      matchedDriverId = sessions.docs.first.data()['driverId'];
      print('🎯 [Passenger] matchedDriverId = $matchedDriverId'); // ✅ add this line
    } else {
      print('⚠️ [Passenger] No ride_sessions found for current user.');
    }
  }


  void _pollForDriverEnd() {
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (matchedDriverId == null) return;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final sessionId = 'session_${currentUser.uid}_$matchedDriverId';
      final session = await FirebaseFirestore.instance
          .collection('ride_sessions')
          .doc(sessionId)
          .get();

      final data = session.data();
      if (data != null) {
        final ended = data['driverEnded'] == true;
        if (ended && !driverEndedRide) {
          setState(() => driverEndedRide = true);
          timer.cancel(); // ✅ only cancel when confirmed
        }
      }
    });
  }


  Future<void> _loadTripData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final passengerInfo = userDoc.data()?['passenger_information'] ?? {};
      final startLat = (passengerInfo['latitude'] as num?)?.toDouble();
      final startLng = (passengerInfo['longitude'] as num?)?.toDouble();

      if (matchedDriverId == null) return;

      final sessionId = 'session_${user.uid}_$matchedDriverId';
      final sessionDoc = await FirebaseFirestore.instance
          .collection('ride_sessions')
          .doc(sessionId)
          .get();
      final dest = sessionDoc.data()?['destination'];
      final destLat = dest?['lat'];
      final destLng = dest?['lng'];

      if (startLat != null && startLng != null) {
        startLocation = await _getLocationName(startLat, startLng);
      }

      if (destLat != null && destLng != null) {
        endLocation = await _getLocationName(destLat, destLng);

        if (startLat != null && startLng != null) {
          final tripDetails = _calculateTripDetails(startLat, startLng, destLat, destLng);
          estimatedTime = tripDetails['time'] ?? "Unknown";
          amount = tripDetails['fare'] ?? "Unknown";
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading trip data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkPaymentMethod() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final cardSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payment_methods')
          .get();

      print('📦 Card count: ${cardSnap.docs.length}');
      for (var doc in cardSnap.docs) {
        print('📄 Card doc ID: ${doc.id}');
        print('🔎 Card data: ${doc.data()}');
      }

      setState(() {
        hasCard = cardSnap.docs.isNotEmpty;
      });
    } catch (e) {
      print("❌ Error checking payment method: $e");
    }
  }

  Future<String> _getLocationName(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng'),
        headers: {
          'User-Agent': 'MyRideApp/1.0 (hcancaglar99@gmail.com)',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      print('Reverse geocoding failed: $e');
      return 'Unknown Location';
    }
  }

  Map<String, String> _calculateTripDetails(double startLat, double startLng, double endLat, double endLng) {
    const R = 6371.0;
    final dLat = _toRadians(endLat - startLat);
    final dLon = _toRadians(endLng - startLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) * cos(_toRadians(endLat)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c;

    final timeInMinutes = (distance / 30 * 60).round();
    final baseFare = 50.0;
    final distanceFare = distance * 15.0;
    final totalFare = baseFare + distanceFare;

    return {
      'time': '$timeInMinutes minutes',
      'fare': '${totalFare.round()} ₺',
    };
  }

  double _toRadians(double deg) => deg * (pi / 180);

  void handlePayment(MyUser user, UserModel? userdata, DatabaseService dbService) async {
    if (!hasCard) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Payment Method"),
          content: const Text("Please add a payment method to your wallet."),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        Provider<MyUser>.value(value: user),
                        StreamProvider<UserModel?>.value(
                          value: dbService.userData,
                          initialData: userdata,
                        ),
                      ],
                      child: AddNewCard(),
                    ),
                  ),
                );
                await _checkPaymentMethod(); // ✅ re-check after returning
                if (hasCard) {
                  setState(() {
                    paymentSuccess = true;
                  });

                  // ✅ Update Firestore to notify driver of completed payment
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null && matchedDriverId != null) {
                    final sessionId = 'session_${currentUser.uid}_$matchedDriverId';
                    await FirebaseFirestore.instance
                        .collection('ride_sessions')
                        .doc(sessionId)
                        .update({'paymentStatus': 'completed'});
                  }

                  _showSuccessDialog();
                }

              },
              child: const Text("Go to Wallet"),
            )
          ],
        ),
      );
      return;
    }

    setState(() => paymentSuccess = true);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Successful"),
        content: const Text("Your ride has been paid successfully."),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final userdata = Provider.of<UserModel?>(context);
    final dbService = DatabaseService(uid: user.uid);
    print('🛠 RideProgressPassenger build triggered, matchedDriverId = $matchedDriverId');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        automaticallyImplyLeading: false,
        title: Text("Ride Progress", style: kAppBarText),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: matchedDriverId == null
                ? const Center(child: CircularProgressIndicator())
                : RoadTripMap(passengerId: FirebaseAuth.instance.currentUser!.uid, driverId: matchedDriverId!),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fillBox,
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_taxi),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(startLocation, style: kFillerText, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_horiz),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(endLocation, style: kFillerText, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Amount: $amount", style: kFillerText),
                const SizedBox(height: 4),
                Text("Estimated Time Left: $estimatedTime", style: kFillerTextSmall),
              ],
            ),
          ),
          const Spacer(),
          if (driverEndedRide && !paymentSuccess)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await _checkPaymentMethod(); // <- Refresh Firestore status
                  handlePayment(user, userdata, dbService);
                },
                child: Text("Make Payment", style: kButtonText),
              ),
            ),
        ],
      ),
    );
  }
}