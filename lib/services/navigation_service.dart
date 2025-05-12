import 'package:flutter/material.dart';
import '../services/database.dart';

class NavigationService {
  final DatabaseService _databaseService = DatabaseService();

  // Cache the result to avoid repeated Firestore calls
  bool? _isDriverCache;

  // Method to clear the cache
  void clearCache() {
    _isDriverCache = null;
  }

  Future<bool> isDriver() async {
    if (_isDriverCache != null) {
      return _isDriverCache!;
    }

    _isDriverCache = await _databaseService.isDriver();
    return _isDriverCache!;
  }

  Future<void> navigateToCorrectProfile(BuildContext context) async {
    try {
      bool isDriver = await this.isDriver();

      if (isDriver) {
        Navigator.pushReplacementNamed(context, '/driver_profile');
      } else {
        Navigator.pushReplacementNamed(context, '/passenger_profile');
      }
    } catch (e) {
      print('Error navigating to profile: $e');
      // Default to passenger profile if there's an error
      Navigator.pushReplacementNamed(context, '/passenger_profile');
    }
  }

  Future<void> navigateToCorrectInformationPage(BuildContext context) async {
    try {
      bool isDriver = await this.isDriver();

      if (isDriver) {
        Navigator.pushNamed(context, '/driver_information');
      } else {
        Navigator.pushNamed(context, '/passenger_information');
      }
    } catch (e) {
      print('Error navigating to information page: $e');
      // Default to passenger information if there's an error
      Navigator.pushNamed(context, '/passenger_information');
    }
  }
}
