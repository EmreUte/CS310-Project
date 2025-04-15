import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../Settings/settings_page.dart';
import '../RideHistory/ride_history.dart';
import '../Preferences/passenger_preferences.dart';
import '../RideMonitoring/finding_your_ride.dart';
import '../digital_payments/digital_payments_page.dart';
class PassengerProfile extends StatelessWidget {
  const PassengerProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        title: const Text(
          "Passenger Name",
          style: TextStyle(color: AppColors.primaryText),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: AppColors.primaryText,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildButtonWithAvatar(context, "Find Your Ride!",  FindingRideScreen()),
              const SizedBox(height: 30),
              _buildButton(context, "Preferences", const PassengerPreferencesScreen()),
              const SizedBox(height: 30),
              _buildButton(context, "Wallet", CreditCardScreen()),
              const SizedBox(height: 30),
              _buildButton(context, "Ride History", const RideHistoryPage()),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/map.png',
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

              // We'll insert the map image here in the next step
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          top: -20,
          left: -7,
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
