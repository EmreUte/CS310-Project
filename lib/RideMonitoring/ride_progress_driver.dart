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

  void _listenForPaymentStatus() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || matchedPassengerId == null) return;

    final sessionId = 'session_${matchedPassengerId}_${currentUser.uid}';
    FirebaseFirestore.instance
        .collection('ride_sessions')
        .doc(sessionId)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      if (data == null) return;

      final paymentStatus = data['paymentStatus'];
      if (paymentStatus == 'completed') {
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
    _listenForPaymentStatus();
  }

  Future<String?> _getMatchedPassengerId() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return null;

    final sessions = await FirebaseFirestore.instance
        .collection('ride_sessions')
        .where('driverId', isEqualTo: currentUid)
        .get();

    if (sessions.docs.isNotEmpty) {
      final passengerId = sessions.docs.first.data()['passengerId'];
      return passengerId;
    } else {
      return null;
    }
  }

  void handleEndRide() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || matchedPassengerId == null) return;

    final sessionId = 'session_${matchedPassengerId}_${currentUser.uid}';
    final sessionRef = FirebaseFirestore.instance.collection('ride_sessions').doc(sessionId);

    try {
      await sessionRef.set({
        'driverEnded': true,
      }, SetOptions(merge: true));

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ending ride. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
