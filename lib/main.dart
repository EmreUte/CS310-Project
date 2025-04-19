import 'package:cs310_project/help_related/faq_page.dart';
import 'package:cs310_project/help_related/help_page.dart';
import 'package:cs310_project/help_related/questions_page.dart';
import 'package:flutter/material.dart';
import 'screens/welcome_page.dart';
import 'digital_payments/digital_payments_page.dart';
import 'digital_payments/add_new_card.dart';
import 'InformationPages/driver_information.dart';
import 'InformationPages/passenger_information.dart';
import 'Profiles/driver_profile.dart';
import 'Profiles/passenger_profile.dart';
import 'package:cs310_project/utils/colors.dart';
import 'RideMonitoring/finding_your_ride.dart';
import 'preferences/passenger_preferences.dart';
import 'preferences/driver_preferences.dart';
import 'Settings/settings_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyRide',
      debugShowCheckedModeBanner: false,
      //  Welcome Page is the landing screen
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/digital_payments_page': (context) => CreditCardScreen(),
        '/add_new_payment': (context) => AddNewCard(),
        '/driver_information': (context) => DriverInformationScreen(),
        '/passenger_information': (context) => PassengerInformationScreen(),
        '/driver_profile': (context) => DriverProfile(),
        '/passenger_profile': (context) => PassengerProfile(),
        '/driver_preferences': (context) => DriverPreferencesScreen(),
        '/passenger_preferences': (context) => PassengerPreferencesScreen(),
        '/finding_your_ride': (context) => FindingRideScreen(),
        '/settings_page': (context) => SettingsPage(),
        '/help_page': (context) => HelpScreen(),
      },
      theme: ThemeData.light().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          elevation: 0.0,
          centerTitle: true,
        ),
      ),
    );
  }
}
