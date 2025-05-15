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

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  Future<void> _loadTripData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Get driver's location from Firestore
      final driverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!driverDoc.exists) return;

      final driverData = driverDoc.data()!;
      final driverInfo = driverData['driver_information'] ?? {};

      double? startLat = driverInfo['latitude']?.toDouble();
      double? startLng = driverInfo['longitude']?.toDouble();

      // Get destination from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final destLat = prefs.getDouble('destination_lat');
      final destLng = prefs.getDouble('destination_lng');





      // Get location names using reverse geocoding
      if (startLat != null && startLng != null) {
        startLocation = await _getLocationName(startLat, startLng);
      }

      if (destLat != null && destLng != null) {
        endLocation = await _getLocationName(destLat, destLng);

        // Calculate estimated time and fare
        if (startLat != null && startLng != null) {
          final tripDetails = _calculateTripDetails(
              startLat, startLng, destLat, destLng
          );

          estimatedTime = tripDetails['time'] ?? "Unknown";
          amount = tripDetails['fare'] ?? "Unknown";
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading trip data: $e');
      setState(() {
        isLoading = false;
      });
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
      double startLat, double startLng, double endLat, double endLng
      ) {
    // Calculate distance using Haversine formula
    const R = 6371.0; // Earth radius in km
    final dLat = _toRadians(endLat - startLat);
    final dLon = _toRadians(endLng - startLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLat)) * cos(_toRadians(endLat)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c;

    // Estimate time (assuming average speed of 30 km/h in city)
    final timeInMinutes = (distance / 30 * 60).round();

    // Calculate fare (base fare + distance fare)
    final baseFare = 50.0;
    final distanceFare = distance * 15.0;
    final totalFare = baseFare + distanceFare;

    return {
      'time': '$timeInMinutes minutes',
      'fare': '${totalFare.round()} ₺',
    };
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  void handleEndRide() async {
    setState(() => rideEnded = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('driverEndedRide', true); // ← NEW

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ride Ended'),
        content: Text('You have successfully ended the ride. Waiting for passenger payment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Ride Progress", style: kAppBarText),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: RoadTripMap(),
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
                    Expanded(
                      child: Text(startLocation, style: kFillerText, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.more_horiz),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(endLocation, style: kFillerText, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text("Amount: $amount", style: kFillerText),
                SizedBox(height: 4),
                Text("Estimated Time Left: $estimatedTime", style: kFillerTextSmall),
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
            )
        ],
      ),
    );
  }
}