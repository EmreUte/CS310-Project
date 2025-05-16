import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ride_session_service.dart'; // NEW
import 'package:shared_preferences/shared_preferences.dart';

class AvailableDrivers extends StatefulWidget {
  final String? matchedDriverId; // NEW
  const AvailableDrivers({super.key,  this.matchedDriverId}); // NEW

  @override
  State<AvailableDrivers> createState() => _AvailableDriversState();
}

class _AvailableDriversState extends State<AvailableDrivers> {
  final LatLng defaultMapCenter = LatLng(41.0082, 28.9784);
  final MapController _mapController = MapController();
  LatLng? passengerPosition;
  List<Map<String, dynamic>> onlineDrivers = [];
  LatLng? selectedDestination;
  StreamSubscription? _driversSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _driversSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && doc.data() != null) {
          final userData = doc.data()!;
          if (userData.containsKey('passenger_information')) {
            final info = userData['passenger_information'];
            if (info['latitude'] != null && info['longitude'] != null) {
              final lat = double.parse(info['latitude'].toString());
              final lng = double.parse(info['longitude'].toString());
              setState(() {
                passengerPosition = LatLng(lat, lng);
                _isLoading = false;
              });
              _mapController.move(LatLng(lat, lng), 14);
            }
          }
        }
      });


      _driversSubscription = FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .where('userType', isEqualTo: 'Driver')
          .snapshots()
          .listen((snapshot) {
        final drivers = snapshot.docs.map((doc) {
          final data = doc.data();
          if (data.containsKey('driver_information')) {
            final info = data['driver_information'];
            if (info['latitude'] != null && info['longitude'] != null) {
              return {
                'id': doc.id,
                'name': data['name'] ?? 'Unknown Driver',
                'position': LatLng(double.parse(info['latitude'].toString()), double.parse(info['longitude'].toString())),
              };
            }
          }
          return null;
        }).where((e) => e != null).cast<Map<String, dynamic>>().toList();

        setState(() {
          onlineDrivers = drivers;
          _isLoading = false;
        });
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {


    setState(() {
      selectedDestination = point;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (widget.matchedDriverId != null) {
      final sessionService = RideSessionService(
        passengerId: currentUser.uid,
        driverId: widget.matchedDriverId!,
      );
      await sessionService.setDestination(point);
    } else {
      // Save destination locally (or set a flag) for use after matching
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('pending_destination_lat', point.latitude);
      await prefs.setDouble('pending_destination_lng', point.longitude);
    }


    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Destination selected at ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            height: 330,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: passengerPosition ?? defaultMapCenter,
                initialZoom: 13,
                onTap: _handleMapTap,
                interactionOptions: const InteractionOptions(
                  enableScrollWheel: true,
                  enableMultiFingerGestureRace: true,
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.cs310_project',
                ),
                if (passengerPosition != null)
                  MarkerLayer(markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: passengerPosition!,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                  ]),
                MarkerLayer(
                  markers: onlineDrivers.map((driver) =>
                      Marker(
                        width: 40,
                        height: 40,
                        point: driver['position'] as LatLng,
                        child: const Icon(Icons.directions_car, color: Colors.red, size: 30),
                      )).toList(),
                ),
                if (selectedDestination != null)
                  MarkerLayer(markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: selectedDestination!,
                      child: const Icon(Icons.flag, color: Colors.green, size: 40),
                    ),
                  ]),
                RichAttributionWidget(attributions: [
                  TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
                ]),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              height: 330,
              color: Colors.white.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Column(children: [
              FloatingActionButton.small(
                heroTag: "zoomIn",
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom + 1);
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: "zoomOut",
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, currentZoom - 1);
                },
                child: const Icon(Icons.remove),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
