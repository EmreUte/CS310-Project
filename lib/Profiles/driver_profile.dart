import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Settings/settings_page.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import '../RideHistory/ride_history.dart';
import '../RideMonitoring/finding_your_ride.dart';
import '../preferences/driver_preferences.dart';
import '../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DriverProfile extends StatefulWidget {

  const DriverProfile({super.key});

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  String userName = "Driver";

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    final dbService = DatabaseService(uid: user!.uid);

    return StreamBuilder<UserModel?>(
        stream: dbService.userData,
        builder: (context, snapshot)
    {
      if (snapshot.hasData && snapshot.data != null) {
        userName = snapshot.data!.name;
      }
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            userName,
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
                _buildButtonWithAvatar(
                    context, "Find Your Passenger!", FindingRideScreen()),
                const SizedBox(height: 90),
                // The other two buttons stay below
                _buildButton(
                    context, "Preferences", const DriverPreferencesScreen()),
                const SizedBox(height: 90),
                _buildButton(context, "Ride History", const RideHistoryPage()),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildButtonWithAvatar(BuildContext context, String label, Widget page) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Button
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
          left: -20,
          top: -20,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.appBarBackground,
                width: 4,
              ),

            ),
            child: ClipOval(
              child: SizedBox(
                width: 88,
                height: 88,
                child: Transform.scale(
                  scale: 1.5,
                  child: Image.network(
                    'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
