import 'package:cs310_project/preferences/driver_preferences.dart';
import 'package:cs310_project/preferences/passenger_preferences.dart';
import 'package:flutter/material.dart';
import 'InformationPages/driver_information.dart';
import 'InformationPages/passenger_information.dart';
import 'Profiles/driver_profile.dart';
import 'digital_payments/add_new_card.dart';
import 'digital_payments/digital_payments_page.dart';
import 'package:cs310_project/utils/colors.dart';

void main() {
  runApp(MaterialApp(
      initialRoute: '/driver_profile',
      routes: {
        '/': (context) => CreditCardScreen(),
        '/digital_payments_page': (context) => CreditCardScreen(),
        '/add_new_payment' : (context) => AddNewCard(),
        '/driver_information':(context) => DriverInformationScreen(),
        '/passenger_information':(context) =>PassengerInformationScreen(),
        '/driver_profile':(context) => DriverProfile(),
        '/driver_preference':(context) => DriverPreferencesScreen(),
        '/passenger_preference':(context) => PassengerPreferencesScreen()
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.appBarBackground,
            elevation: 0.0,
            centerTitle: true,
          )
      )
  ),
  );
}
