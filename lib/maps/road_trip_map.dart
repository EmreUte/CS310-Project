import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;


class RoadTripMap extends StatefulWidget {
  const RoadTripMap({super.key});

  @override
  State<RoadTripMap> createState() => _RoadTripMapState();
}

class _RoadTripMapState extends State<RoadTripMap> {
  // Default center on Istanbul
  final LatLng defaultMapCenter = LatLng(41.0082, 28.9784);

  // Map controller for programmatic control
  final MapController _mapController = MapController();

  // Start and end positions
  LatLng? startPosition;
  LatLng? destinationPosition;

  // Current car position for animation
  LatLng? currentCarPosition;

  // Animation control
  Timer? _animationTimer;
  double _progress = 0.0;
  final int _animationDurationSeconds = 5;
  final int _animationSteps = 60; // 60 frames per second for 5 seconds = 300 steps
  bool _isAnimationComplete = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadPositions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load destination from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final destLat = prefs.getDouble('destination_lat');
      final destLng = prefs.getDouble('destination_lng');

      if (destLat != null && destLng != null) {
        destinationPosition = LatLng(destLat, destLng);
        print('Loaded destination: $destLat, $destLng');
      } else {
        print('No destination found in SharedPreferences');
      }

      // Load start position from Firestore
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;

          // Check if user is passenger or driver
          if (userData['userType'] == 'Passenger' && userData.containsKey('passenger_information')) {
            final passengerInfo = userData['passenger_information'];
            if (passengerInfo != null &&
                passengerInfo['latitude'] != null &&
                passengerInfo['longitude'] != null) {
              final lat = passengerInfo['latitude'];
              final lng = passengerInfo['longitude'];
              startPosition = LatLng(
                double.parse(lat.toString()),
                double.parse(lng.toString()),
              );
              print('Loaded passenger start position: $lat, $lng');
            }
          } else if (userData['userType'] == 'Driver' && userData.containsKey('driver_information')) {
            final driverInfo = userData['driver_information'];
            if (driverInfo != null &&
                driverInfo['latitude'] != null &&
                driverInfo['longitude'] != null) {
              final lat = driverInfo['latitude'];
              final lng = driverInfo['longitude'];
              startPosition = LatLng(
                double.parse(lat.toString()),
                double.parse(lng.toString()),
              );
              print('Loaded driver start position: $lat, $lng');
            }
          }
        }
      }

      // Initialize car position at start position
      if (startPosition != null) {
        currentCarPosition = startPosition;
      }

      setState(() {
        _isLoading = false;
      });

      // Center map to show both points
      if (startPosition != null && destinationPosition != null) {
        _centerMapOnRoute();
        // Start animation after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _startAnimation();
        });
      }
    } catch (e) {
      print('Error loading positions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _centerMapOnRoute() {
    if (startPosition == null || destinationPosition == null) return;

    // Calculate the center point between start and destination
    final centerLat = (startPosition!.latitude + destinationPosition!.latitude) / 2;
    final centerLng = (startPosition!.longitude + destinationPosition!.longitude) / 2;

    // Calculate appropriate zoom level
    final latDiff = (startPosition!.latitude - destinationPosition!.latitude).abs();
    final lngDiff = (startPosition!.longitude - destinationPosition!.longitude).abs();
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Simple formula to calculate zoom level based on distance
    // Adjust the divisor to get appropriate zoom for your specific use case
    final zoom = maxDiff < 0.01 ? 14.0 : maxDiff < 0.05 ? 12.0 : 10.0;

    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  void _startAnimation() {
    if (startPosition == null || destinationPosition == null) return;

    // Calculate time per step based on total duration and steps
    final stepDuration = Duration(
        milliseconds: (_animationDurationSeconds * 1000) ~/ _animationSteps
    );

    _animationTimer = Timer.periodic(stepDuration, (timer) {
      setState(() {
        // Increment progress
        _progress += 1.0 / _animationSteps;

        if (_progress >= 1.0) {
          _progress = 1.0;
          _isAnimationComplete = true;
          timer.cancel();
        }

        // Interpolate between start and destination
        currentCarPosition = _interpolatePosition(
            startPosition!,
            destinationPosition!,
            _progress
        );
      });
    });
  }

  LatLng _interpolatePosition(LatLng start, LatLng end, double progress) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * progress,
      start.longitude + (end.longitude - start.longitude) * progress,
    );
  }

  // Calculate rotation angle for the car icon to face the direction of travel
  double _calculateRotationAngle() {
    if (startPosition == null || destinationPosition == null) return 0;

    final dx = destinationPosition!.longitude - startPosition!.longitude;
    final dy = destinationPosition!.latitude - startPosition!.latitude;

    if (dx == 0 && dy == 0) return 0;

    return -1 * (dx.isNegative ? 3.14159 : 0) + (dy == 0 ? 0 : (dx == 0 ? 1.5708 : dx.isNegative ? -1 : 1) * (dy.isNegative ? -1 : 1) * math.atan(dx.abs() / dy.abs()));

  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: startPosition ?? defaultMapCenter,
              initialZoom: 13,
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
              // Start position marker
              if (startPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: startPosition!,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                    ),
                  ],
                ),
              // Destination marker
              if (destinationPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: destinationPosition!,
                      child: const Icon(Icons.flag, color: Colors.green, size: 40),
                    ),
                  ],
                ),
              // Moving car marker
              if (currentCarPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: currentCarPosition!,
                      child: Transform.rotate(
                        angle: _calculateRotationAngle(),
                        child: const Icon(Icons.directions_car, color: Colors.red, size: 30),
                      ),
                    ),
                  ],
                ),
              // Attribution widget
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

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Progress indicator
          if (startPosition != null && destinationPosition != null)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: FractionallySizedBox(
                  widthFactor: _progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
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

          // Trip status
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isAnimationComplete
                    ? "Trip completed!"
                    : "Trip in progress: ${(_progress * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
