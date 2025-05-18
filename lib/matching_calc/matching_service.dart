// lib/matching/matching_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';


Future<List<MatchPair>> findBestMatches({
  int iterations = 1000,
  double initialTemp = 100,
  double coolingRate = 0.99,
}) async {
  final firestore = FirebaseFirestore.instance;
  final userSnap = await firestore.collection('users').get();
  final drivers = <Driver>[];
  final passengers = <Passenger>[];

  for (var doc in userSnap.docs) {
    final data = doc.data();
    if (data.containsKey('driver_information')) {
      drivers.add(Driver.fromUserDoc(doc.id, data));
    }
    if (data.containsKey('passenger_information')) {
      passengers.add(Passenger.fromUserDoc(doc.id, data));
    }
  }

  // Euclidean distance up to a cutoff
  double _distance(Driver d, Passenger p) {
    final dx = d.latitude - p.latitude;
    final dy = d.longitude - p.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  // Valid only if luggage fits and distance ≤ 1
  bool _valid(Driver d, Passenger p) {
    return d.luggageCapacity >= p.luggage && _distance(d, p) <= 1;
  }

  // Driver satisfaction: count of criteria met
  double _sd(Driver d, Passenger p) {
    var score = 0;
    if (d.tipAmount <= p.tipAmount) score++;
    if (d.genderPreference == 0 || d.genderPreference == p.gender) score++;
    if (d.smokingPreference == p.smokingPreference) score++;
    if (d.ratingPreference <= p.rating) score++;
    return score.toDouble();
  }

  // Passenger satisfaction: count of criteria met
  double _sp(Driver d, Passenger p) {
    var score = 0;
    if (p.driverGenderPreference == 0 || d.gender == p.driverGenderPreference) score++;
    if (p.carTypePreference == 'Any' || d.carType == p.carTypePreference) score++;
    if (d.rating >= p.passengerRatingPreference) score++;
    if (d.driverExperience >= p.requestedDriverExperience) score++;
    if (d.smokingPreference == p.smokingPreference) score++;
    return score.toDouble();
  }

  // Combined energy: sd + sp – distance, shifted to stay positive
  double _energy(Driver d, Passenger p) {
    final raw = _sd(d, p) + _sp(d, p) - _distance(d, p);
    const kShift = 100;  // large enough to keep energy positive
    return raw + kShift;
  }

  // Generate all valid pairs
  List<MatchPair> _generatePairs() =>
      [for (var d in drivers) for (var p in passengers) if (_valid(d, p)) MatchPair(d, p)];

  // Greedy initial matching by decreasing energy
  List<MatchPair> _initialSolution() {
    final pairs = _generatePairs()
      ..sort((a, b) => _energy(b.driver, b.passenger).compareTo(_energy(a.driver, a.passenger)));
    final sol = <MatchPair>[];
    final usedD = <String>{}, usedP = <String>{};
    for (var m in pairs) {
      if (usedD.add(m.driver.id) && usedP.add(m.passenger.id)) sol.add(m);
    }
    return sol;
  }

  List<MatchPair> _randomNeighbor(List<MatchPair> cur) {
    final rnd = Random();
    // Start from the current solution unchanged:
    final curCopy = List<MatchPair>.from(cur);

    // Find all drivers & passengers not yet matched, and valid pairs among them:
    final available = <MatchPair>[];
    final usedDrivers = cur.map((m) => m.driver.id).toSet();
    final usedPassengers = cur.map((m) => m.passenger.id).toSet();

    for (var d in drivers) {
      if (usedDrivers.contains(d.id)) continue;
      for (var p in passengers) {
        if (usedPassengers.contains(p.id)) continue;
        if (_valid(d, p)) {
          available.add(MatchPair(d, p));
        }
      }
    }

    // If there’s at least one possible addition, add one at random:
    if (available.isNotEmpty) {
      curCopy.add(available[rnd.nextInt(available.length)]);
    }

    return curCopy;
  }

  // Simulated Annealing
  var current = _initialSolution();
  double currentE =
  current.map((m) => _energy(m.driver, m.passenger)).fold(0.0, (a, b) => a + b);
  var best = List<MatchPair>.from(current);
  var bestE = currentE;
  var temp = initialTemp;
  final rnd = Random();

  for (var i = 0; i < iterations; i++) {
    final cand = _randomNeighbor(current);
    final candE = cand.map((m) => _energy(m.driver, m.passenger)).fold(0.0, (a, b) => a + b);
    final delta = candE - currentE;
    if (delta > 0 || exp(delta / temp) > rnd.nextDouble()) {
      current = cand;
      currentE = candE;
      if (currentE > bestE) {
        best = List<MatchPair>.from(current);
        bestE = currentE;
      }
    }
    temp *= coolingRate;
  }

  return best;
}
