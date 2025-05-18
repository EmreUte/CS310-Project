import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../services/ride_session_service.dart';

class RoadTripMap extends StatefulWidget {
  final String passengerId;
  final String driverId;

  const RoadTripMap({
    super.key,
    required this.passengerId,
    required this.driverId,
  });

  @override
  State<RoadTripMap> createState() => _RoadTripMapState();
}

class _RoadTripMapState extends State<RoadTripMap> {
  final LatLng defaultMapCenter = LatLng(41.0082, 28.9784);
  final MapController _mapController = MapController();
  LatLng? startPosition;
  LatLng? destinationPosition;
  LatLng? currentCarPosition;
  Timer? _animationTimer;
  double _progress = 0.0;
  final int _animationDurationSeconds = 5;
  final int _animationSteps = 60;
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
      final rideSession = RideSessionService(
        passengerId: widget.passengerId,
        driverId: widget.driverId,
      );

      final dest = await rideSession.getDestination().catchError((e) {});
      if (dest != null) {
        destinationPosition = dest;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get()
          .catchError((e) {});

      final passengerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.passengerId)
          .get();

      if (passengerDoc.exists) {
        final passengerData = passengerDoc.data()?['passenger_information'];
        final lat = passengerData?['latitude'];
        final lng = passengerData?['longitude'];

        if (lat != null && lng != null) {
          startPosition = LatLng(double.parse(lat.toString()), double.parse(lng.toString()));
        }
      }

      if (startPosition != null) {
        currentCarPosition = startPosition;
      }

      setState(() => _isLoading = false);

      if (startPosition != null && destinationPosition != null) {
        _centerMapOnRoute();
        Future.delayed(const Duration(milliseconds: 500), _startAnimation);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _centerMapOnRoute() {
    if (startPosition == null || destinationPosition == null) return;
    final centerLat = (startPosition!.latitude + destinationPosition!.latitude) / 2;
    final centerLng = (startPosition!.longitude + destinationPosition!.longitude) / 2;
    final latDiff = (startPosition!.latitude - destinationPosition!.latitude).abs();
    final lngDiff = (startPosition!.longitude - destinationPosition!.longitude).abs();
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    final zoom = maxDiff < 0.01 ? 14.0 : maxDiff < 0.05 ? 12.0 : 10.0;
    _mapController.move(LatLng(centerLat, centerLng), zoom);
  }

  void _startAnimation() {
    if (startPosition == null || destinationPosition == null) return;
    final stepDuration = Duration(
        milliseconds: (_animationDurationSeconds * 1000) ~/ _animationSteps);

    _animationTimer = Timer.periodic(stepDuration, (timer) {
      setState(() {
        _progress += 1.0 / _animationSteps;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _isAnimationComplete = true;
          timer.cancel();
        }
        currentCarPosition = _interpolatePosition(
            startPosition!, destinationPosition!, _progress);
      });
    });
  }

  LatLng _interpolatePosition(LatLng start, LatLng end, double progress) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * progress,
      start.longitude + (end.longitude - start.longitude) * progress,
    );
  }

  double _calculateRotationAngle() {
    if (startPosition == null || destinationPosition == null) return 0;
    final dx = destinationPosition!.longitude - startPosition!.longitude;
    final dy = destinationPosition!.latitude - startPosition!.latitude;
    if (dx == 0 && dy == 0) return 0;
    return -1 * (dx.isNegative ? 3.14159 : 0) +
        (dy == 0
            ? 0
            : (dx == 0
            ? 1.5708
            : dx.isNegative
            ? -1
            : 1) *
            (dy.isNegative ? -1 : 1) *
            math.atan(dx.abs() / dy.abs()));
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
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
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
