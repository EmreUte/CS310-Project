import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Settings/settings_page.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../RideHistory/ride_history.dart';
import '../Preferences/passenger_preferences.dart';
import '../RideMonitoring/finding_your_ride.dart';
import '../digital_payments/digital_payments_page.dart';
import '../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../maps/available_drivers.dart';



class PassengerProfile extends StatefulWidget {
  const PassengerProfile({super.key});

  @override
  State<PassengerProfile> createState() => _PassengerProfileState();
}

class _PassengerProfileState extends State<PassengerProfile> {
  String userName = "Passenger";

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
          centerTitle: true,
          backgroundColor: AppColors.appBarBackground,
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
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButtonWithAvatar(
                    context, "Find Your Ride!", FindingRideScreen()),
                const SizedBox(height: 30),
                _buildButton(
                    context, "Preferences", const PassengerPreferencesScreen()),
                const SizedBox(height: 30),
                _buildButton(context, "Wallet", CreditCardScreen()),
                const SizedBox(height: 30),
                _buildButton(context, "Ride History", const RideHistoryPage()),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 330, // or adjust to desired height
                  child: const AvailableDrivers(),
                ),
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
          if (label == "Ride History") {
            final user = Provider.of<MyUser?>(context, listen: false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamProvider<List<RideRecord>?>.value(
                  value: DatabaseService(uid: user!.uid).rideHistory,
                  initialData: null,
                  child: page,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
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
