import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../maps/road_trip_map.dart';
import 'dart:async';


class RideProgressPassenger extends StatefulWidget {
  @override
  _RideProgressPassengerState createState() => _RideProgressPassengerState();
}

class _RideProgressPassengerState extends State<RideProgressPassenger> {
  bool paymentSuccess = false;
  bool isLoading = true;
  bool hasCard = false;

  String startLocation = "Loading...";
  String endLocation = "Loading...";
  String estimatedTime = "Calculating...";
  String amount = "Calculating...";

  bool driverEndedRide = false;

  Future<void> _checkIfDriverEndedRide() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      driverEndedRide = prefs.getBool('driverEndedRide') ?? false;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadTripData();
    _checkPaymentMethod();
    _checkIfDriverEndedRide();

    Timer.periodic(Duration(seconds: 2), (timer) {
      _checkIfDriverEndedRide();
      if (driverEndedRide) timer.cancel();
    });
  }

  Future<void> _loadTripData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();
      final passengerInfo = data?['passenger_information'] ?? {};
      final startLat = (passengerInfo['latitude'] as num?)?.toDouble();
      final startLng = (passengerInfo['longitude'] as num?)?.toDouble();

      final prefs = await SharedPreferences.getInstance();
      final destLat = prefs.getDouble('destination_lat');
      final destLng = prefs.getDouble('destination_lng');

      if (startLat != null && startLng != null) {
        startLocation = await _getLocationName(startLat, startLng);
      }

      if (destLat != null && destLng != null) {
        endLocation = await _getLocationName(destLat, destLng);

        if (startLat != null && startLng != null) {
          final tripDetails = _calculateTripDetails(
              startLat, startLng, destLat, destLng);
          estimatedTime = tripDetails['time'] ?? "Unknown";
          amount = tripDetails['fare'] ?? "Unknown";
        }
      }

      setState(() {
        isLoading = false;
      });
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

      setState(() {
        hasCard = cardSnap.docs.isNotEmpty;
      });
    } catch (e) {
      print("Error checking payment method: $e");
    }
  }

  Future<String> _getLocationName(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng'),
        headers: {
          'User-Agent': 'MyRideApp/1.0 (hcancaglar99@gmail.com)',  // use a valid email or domain
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final displayName = data['display_name'];
        return displayName ?? 'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      print('Reverse geocoding failed: $e');
      return 'Unknown Location';
    }
  }



  Map<String, String> _calculateTripDetails(
      double startLat, double startLng, double endLat, double endLng) {
    const R = 6371.0;
    final dLat = _toRadians(endLat - startLat);
    final dLon = _toRadians(endLng - startLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) *
            cos(_toRadians(endLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
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

  void handlePayment() {
    if (!hasCard) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("No Payment Method"),
          content:
          const Text("Please add a payment method to your wallet."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/digital_payments_page');
              },
              child: const Text("Go to Wallet"),
            )
          ],
        ),
      );
      return;
    }

    setState(() => paymentSuccess = true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Successful"),
        content: const Text("Your ride has been paid successfully."),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(
                context, ModalRoute.withName('/passenger_profile')),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined,
              size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.popUntil(
              context, ModalRoute.withName('/passenger_profile')),
        ),
        title: Text("Ride Progress", style: kAppBarText),
      ),
      body: Column(
        children: [
          SizedBox(height: 300, child: const RoadTripMap()),
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
                      child: Text(startLocation,
                          style: kFillerText,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_horiz),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(endLocation,
                          style: kFillerText,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Amount: $amount", style: kFillerText),
                const SizedBox(height: 4),
                Text("Estimated Time Left: $estimatedTime",
                    style: kFillerTextSmall),
              ],
            ),
          ),
          const Spacer(),
          if (driverEndedRide && !paymentSuccess)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: handlePayment,
                child: Text("Make Payment", style: kButtonText),
              ),
            ),
        ],
      ),
    );
  }
}
