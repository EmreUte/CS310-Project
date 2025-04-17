import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import '../Settings/settings_page.dart';
import '../RideHistory/ride_history.dart';
import '../Preferences/preferences.dart';
import '../RideMonitoring/finding_your_ride.dart';
import '../preferences/driver_preferences.dart';

class DriverProfile extends StatelessWidget {
  const DriverProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Driver Name",
          style: kHeadingText.copyWith(color: AppColors.primaryText),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: AppColors.primaryText,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 90),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildButtonWithAvatar(context, "Find Your Passenger!", FindingRideScreen()),
              const SizedBox(height: 90),
              // The other two buttons stay below
              _buildButton(context, "Preferences", const DriverPreferencesScreen()),
              const SizedBox(height: 90),
              _buildButton(context, "Ride History", const RideHistoryPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonWithAvatar(BuildContext context, String label, Widget page) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => page),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBackground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: kButtonText,

            ),
          ),
        ),
        Positioned(
          left: -14,
           top:-15,

          child: _buildAvatar(),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFEADDFF),
        borderRadius: BorderRadius.circular(55),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Center(
        child: Icon(

          Icons.person_outline,
          size: 80,
          color: Color(0xFF4F378A),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, Widget page) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: kButtonText,
        ),
      ),
    );
  }
}
