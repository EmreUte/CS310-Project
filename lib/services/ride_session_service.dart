import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class RideSessionService {
  final String passengerId;
  final String driverId;

  RideSessionService({required this.passengerId, required this.driverId});

  String get _sessionId => 'session_${passengerId}_$driverId';

  CollectionReference get _sessionRef =>
      FirebaseFirestore.instance.collection('ride_sessions');

  Map<String, dynamic> get _sessionIdentifiers => {
    'driverId': driverId,
    'passengerId': passengerId,
  };

  Future<void> setDestination(LatLng latLng) async {
    await _sessionRef.doc(_sessionId).set({
      ..._sessionIdentifiers,
      'destination': {
        'lat': latLng.latitude,
        'lng': latLng.longitude,
      }
    }, SetOptions(merge: true));
  }

  Future<LatLng?> getDestination() async {
    final doc = await _sessionRef.doc(_sessionId).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data != null && data['destination'] != null) {
      return LatLng(data['destination']['lat'], data['destination']['lng']);
    }
    return null;
  }

  Future<void> setUserReady(String role) async {
    await _sessionRef.doc(_sessionId).set({
      ..._sessionIdentifiers,
      '${role.toLowerCase()}Ready': true,
    }, SetOptions(merge: true));
  }


  Future<bool> isBothReady() async {
    final doc = await _sessionRef.doc(_sessionId).get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['driverReady'] == true && data?['passengerReady'] == true;
  }

  Future<void> markRideEnded() async {
    await _sessionRef.doc(_sessionId).update({'driverEnded': true});
  }

  Future<bool> hasDriverEndedRide() async {
    final doc = await _sessionRef.doc(_sessionId).get();
    final data = doc.data() as Map<String, dynamic>?;
    return data?['driverEnded'] == true;
  }

  Future<void> clearSession() async {
    await _sessionRef.doc(_sessionId).delete();
  }
}
