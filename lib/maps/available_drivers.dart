import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailableDrivers extends StatefulWidget {
  const AvailableDrivers({super.key});

  @override
  State<AvailableDrivers> createState() => _AvailableDriversState();
}

class _AvailableDriversState extends State<AvailableDrivers> {
  // Default center on Istanbul
  final LatLng defaultMapCenter = LatLng(41.0082, 28.9784);

  // Map controller for programmatic control
  final MapController _mapController = MapController();

  // Store passenger and driver positions
  LatLng? passengerPosition;
  List<Map<String, dynamic>> onlineDrivers = [];

  // Selected destination
  LatLng? selectedDestination;
  String? destinationAddress;

  // Subscription to Firestore updates
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
      // Get passenger position
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;

        // Check for passenger information in the nested structure
        if (userData.containsKey('passenger_information')) {
          final passengerInfo = userData['passenger_information'];

          if (passengerInfo != null &&
              passengerInfo['latitude'] != null &&
              passengerInfo['longitude'] != null) {

            final lat = passengerInfo['latitude'];
            final lng = passengerInfo['longitude'];

            print('Passenger position found: $lat, $lng');

            setState(() {
              passengerPosition = LatLng(
                double.parse(lat.toString()),
                double.parse(lng.toString()),
              );
            });

            // Center map on passenger position with a slight delay to ensure map is ready
            Future.delayed(const Duration(milliseconds: 500), () {
              if (passengerPosition != null && _mapController != null) {
                _mapController.move(passengerPosition!, 14);
                print('Map centered on passenger position');
              }
            });
          } else {
            print('Passenger location data incomplete or missing');
          }
        } else {
          print('No passenger_information found in user document');
        }
      }

      // Listen for online drivers
      _driversSubscription = FirebaseFirestore.instance
          .collection('users')
          .where('isOnline', isEqualTo: true)
          .where('userType', isEqualTo: 'Driver')
          .snapshots()
          .listen((snapshot) {
        print('Found ${snapshot.docs.length} online drivers');

        final drivers = snapshot.docs.map((doc) {
          final data = doc.data();

          // Check if driver information exists in the nested structure
          if (data.containsKey('driver_information')) {
            final driverInfo = data['driver_information'];

            if (driverInfo != null &&
                driverInfo['latitude'] != null &&
                driverInfo['longitude'] != null) {

              final lat = driverInfo['latitude'];
              final lng = driverInfo['longitude'];

              return {
                'id': doc.id,
                'name': data['name'] ?? 'Unknown Driver',
                'position': LatLng(
                  double.parse(lat.toString()),
                  double.parse(lng.toString()),
                ),
              };
            }
          }
          return null;
        })
            .where((item) => item != null)
            .cast<Map<String, dynamic>>()
            .toList();

        setState(() {
          onlineDrivers = drivers;
          _isLoading = false;
        });

        print('Processed ${onlineDrivers.length} drivers with valid locations');
      }, onError: (e) {
        print('Error loading drivers: $e');
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      print('Error in _loadUserData: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      selectedDestination = point;
    });

    // Store destination in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('destination_lat', point.latitude);
    await prefs.setDouble('destination_lng', point.longitude);

    // Show a snackbar to confirm destination selection
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Destination selected at ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}'),
          duration: const Duration(seconds: 2),
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
            height: 330, // Match the height from passenger_profile
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
                // Show passenger marker
                if (passengerPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: passengerPosition!,
                        child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                      ),
                    ],
                  ),
                // Show driver markers
                MarkerLayer(
                  markers: onlineDrivers.map((driver) =>
                      Marker(
                        width: 40,
                        height: 40,
                        point: driver['position'] as LatLng,
                        child: const Icon(Icons.directions_car, color: Colors.red, size: 30),
                      )
                  ).toList(),
                ),
                // Show selected destination marker
                if (selectedDestination != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: selectedDestination!,
                        child: const Icon(Icons.flag, color: Colors.green, size: 40),
                      ),
                    ],
                  ),
                // Add zoom control buttons
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              height: 330,
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          // Zoom controls
          Positioned(
            right: 10,
            bottom: 10,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoomIn",
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom + 1,
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoomOut",
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      currentZoom - 1,
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
