// lib/matching_calc/models.dart

import 'dart:math';


int _safeInt(dynamic v, {int defaultValue = 0}) {
  if (v == null) return defaultValue;
  final s = v.toString();
  return int.tryParse(s) ?? defaultValue;
}


int _genderPrefToInt(dynamic v) {
  if (v is int) return v;
  final s = v.toString().toLowerCase();
  if (s == 'male') return 1;
  if (s == 'female') return 2;
  return 0; // None/unspecified
}

/// Converts smoking preference string/int to our internal code.
int _smokePrefToInt(dynamic v) {
  if (v is int) return v;
  final s = v.toString().toLowerCase();
  return (s.contains('smoking')) ? 1 : 0;
}

class Driver {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int luggageCapacity;
  final int tipAmount;
  final int genderPreference;
  final int smokingPreference;
  final int ratingPreference;
  final int gender;
  final int rating;
  final int driverExperience;
  final String carType;

  Driver({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.luggageCapacity,
    required this.tipAmount,
    required this.genderPreference,
    required this.smokingPreference,
    required this.ratingPreference,
    required this.gender,
    required this.rating,
    required this.driverExperience,
    required this.carType,
  });


  factory Driver.fromUserDoc(String id, Map<String, dynamic> data) {
    final rootName = data['name'] as String?;
    final d = data['driver_information'] as Map<String, dynamic>? ?? {};

    return Driver(
      id: id,
      name: rootName ?? id,
      latitude: (d['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (d['longitude'] as num?)?.toDouble() ?? 0.0,
      luggageCapacity:    _safeInt(d['luggage_capacity']),
      tipAmount:          _safeInt(d['tip']),
      genderPreference:   _genderPrefToInt(d['gender_preference']),
      smokingPreference:  _smokePrefToInt(d['smoking_preference']),
      ratingPreference:   _safeInt(d['preferred_rating']),
      gender:             _genderPrefToInt(d['driver_gender']),
      rating:             _safeInt(d['driver_rating']),
      driverExperience:   _safeInt(d['driving_experience']),
      carType:            d['car_type'] as String? ?? 'Any',
    );
  }
}

class Passenger {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int luggage;
  final int tipAmount;
  final int gender;
  final int smokingPreference;
  final int rating;
  final int driverGenderPreference;
  final int passengerRatingPreference;
  final int requestedDriverExperience;
  final String carTypePreference;

  Passenger({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.luggage,
    required this.tipAmount,
    required this.gender,
    required this.smokingPreference,
    required this.rating,
    required this.driverGenderPreference,
    required this.passengerRatingPreference,
    required this.requestedDriverExperience,
    required this.carTypePreference,
  });


  factory Passenger.fromUserDoc(String id, Map<String, dynamic> data) {
    final rootName = data['name'] as String?;
    final p = data['passenger_information'] as Map<String, dynamic>? ?? {};

    return Passenger(
      id: id,
      name: rootName ?? id,
      latitude: (p['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (p['longitude'] as num?)?.toDouble() ?? 0.0,
      luggage:                  _safeInt(p['luggage']),
      tipAmount:                _safeInt(p['tip']),
      gender:                   _genderPrefToInt(p['passenger_gender']),
      smokingPreference:        _smokePrefToInt(p['smoking_preference']),
      rating:                   _safeInt(p['passenger_rating']),
      driverGenderPreference:   _genderPrefToInt(p['gender_preference']),
      passengerRatingPreference: _safeInt(p['preferred_rating']),
      requestedDriverExperience: _safeInt(p['requested_driver_exp']),
      carTypePreference:         p['car_type_preference'] as String? ?? 'Any',
    );
  }
}

class MatchPair {
  final Driver driver;
  final Passenger passenger;

  MatchPair(this.driver, this.passenger);
}
