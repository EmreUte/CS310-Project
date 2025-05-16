import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../maps/road_trip_map.dart';
import 'dart:async';

class RideProgressDriver extends StatefulWidget {
  @override
  _RideProgressDriverState createState() => _RideProgressDriverState();
}

class _RideProgressDriverState extends State<RideProgressDriver> {
  bool rideEnded = false;
  bool isLoading = true;
  String startLocation = "Loading...";
  String endLocation = "Loading...";
  String estimatedTime = "Calculating...";
  String amount = "Calculating...";
  String? matchedPassengerId;
  Timer? _paymentTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _paymentTimer?.cancel();
    super.dispose();
  }

  void _pollForPayment() {
    _paymentTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || matchedPassengerId == null) return;

      final sessionId = 'session_${matchedPassengerId}_${currentUser.uid}';
      final sessionDoc = await FirebaseFirestore.instance
          .collection('ride_sessions')
          .doc(sessionId)
          .get();

      final data = sessionDoc.data();
      if (data?['paymentStatus'] == 'completed') {
        timer.cancel();
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Payment Received"),
            content: const Text("Passenger has completed the payment."),
            actions: [
              TextButton(
                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    });
  }

  Future<void> _initialize() async {
    matchedPassengerId = await _getMatchedPassengerId();
    print('🎯 [Driver] matchedPassengerId = \$matchedPassengerId');
    await _loadTripData();
    _pollForPayment();
  }

  Future<String?> _getMatchedPassengerId() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final sessions = await FirebaseFirestore.instance
        .collection('ride_sessions')
        .where('driverId', isEqualTo: currentUid)
        .get();

    if (sessions.docs.isNotEmpty) {
      return sessions.docs.first.data()['passengerId'];
    }
    return null;
  }

  Future<void> _loadTripData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || matchedPassengerId == null) return;

      final driverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!driverDoc.exists) return;

      final driverData = driverDoc.data()!;
      final driverInfo = driverData['driver_information'] ?? {};

      double? startLat = driverInfo['latitude']?.toDouble();
      double? startLng = driverInfo['longitude']?.toDouble();

      final sessionDoc = await FirebaseFirestore.instance
          .collection('ride_sessions')
          .doc('session_\${matchedPassengerId}_\${currentUser.uid}')
          .get();

      final dest = sessionDoc.data()?['destination'];
      final destLat = dest?['lat'];
      final destLng = dest?['lng'];

      if (startLat != null && startLng != null) {
        startLocation = await _getLocationName(startLat, startLng);
      }

      if (destLat != null && destLng != null) {
        endLocation = await _getLocationName(destLat, destLng);
        final tripDetails = _calculateTripDetails(startLat!, startLng!, destLat, destLng);
        estimatedTime = tripDetails['time'] ?? "Unknown";
        amount = tripDetails['fare'] ?? "Unknown";
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading trip data: \$e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _getLocationName(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=\$lat&lon=\$lng'),
        headers: {'User-Agent': 'MyRideApp/1.0 (hcancaglar99@gmail.com)'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      print('Reverse geocoding failed: \$e');
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
    return {'time': '\$timeInMinutes minutes', 'fare': '\${totalFare.round()} ₺'};
  }

  double _toRadians(double degree) => degree * (pi / 180);

  void handleEndRide() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || matchedPassengerId == null) return;

    final sessionId = 'session_${matchedPassengerId}_${currentUser.uid}';
    final sessionRef = FirebaseFirestore.instance.collection('ride_sessions').doc(sessionId);

    try {
      await sessionRef.set({
        'driverEnded': true,
      }, SetOptions(merge: true)); // ✅ ensures other fields are preserved

      setState(() => rideEnded = true);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ride Ended'),
          content: Text('You have successfully ended the ride. Waiting for passenger payment.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      print('❌ Failed to mark ride ended: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ending ride. Please try again.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    print('🛠 RideProgressDriver build triggered, matchedPassengerId = \$matchedPassengerId');
    final driverId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Ride Progress", style: kAppBarText),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: matchedPassengerId == null
                ? Center(child: CircularProgressIndicator())
                : RoadTripMap(passengerId: matchedPassengerId!, driverId: driverId),
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
                ? Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_taxi),
                    SizedBox(width: 8),
                    Expanded(child: Text(startLocation, style: kFillerText, overflow: TextOverflow.ellipsis)),
                    SizedBox(width: 8),
                    Icon(Icons.more_horiz),
                    SizedBox(width: 8),
                    Expanded(child: Text(endLocation, style: kFillerText, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                SizedBox(height: 8),
                Text("Amount: \$amount", style: kFillerText),
                SizedBox(height: 4),
                Text("Estimated Time Left: \$estimatedTime", style: kFillerTextSmall),
              ],
            ),
          ),
          const Spacer(),
          if (!rideEnded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBackground,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: handleEndRide,
                child: Text("End Ride", style: kButtonText),
              ),
            ),
          if (rideEnded)
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text("Waiting for passenger to make payment...", style: kFillerTextSmall),
            ),
        ],
      ),
    );
  }
}
