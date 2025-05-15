import 'package:cs310_project/services/auth.dart';
import 'package:cs310_project/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'error_page.dart';
import 'package:cs310_project/help_related/faq_page.dart';
import 'package:cs310_project/help_related/help_page.dart';
import 'loading_page.dart';
import 'models/user_model.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
              home: ErrorPage(errorDetail: "Firebase App could not be initialized!",));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamProvider<MyUser?>.value(
              value: AuthService().user,
              initialData: null,
              child: MaterialApp(
                  title: 'MyRide',
                  debugShowCheckedModeBanner: false,
                  initialRoute: '/passenger_profile',
                  routes: {
                    '/': (context) => const Wrapper(),
                    '/add_new_payment': (context) => AddNewCard(),
                    '/driver_information': (context) => DriverInformationScreen(),
                    '/passenger_profile': (context) => PassengerProfile(),
                    '/driver_profile': (context) => DriverProfile(),
                    '/passenger_information': (context) => PassengerInformationScreen(),
                    '/driver_preferences': (context) => DriverPreferencesScreen(),
                    '/passenger_preferences': (context) => PassengerPreferencesScreen(),
                    '/finding_your_ride': (context) => FindingRideScreen(),
                    '/help_page': (context) => HelpScreen(),
                    '/faq_page': (context) => FaqScreen(),
                  },
                  theme: ThemeData.light().copyWith(
                    appBarTheme: AppBarTheme(
                      backgroundColor: AppColors.appBarBackground,
                      elevation: 0.0,
                      centerTitle: true,
                    ),
                    scaffoldBackgroundColor: Colors.white,
                  ),
              ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
            home: LoadingPage());
      },
    );
  }
}
