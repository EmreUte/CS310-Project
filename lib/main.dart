import 'package:flutter/material.dart';
import 'InformationPages/passenger_information.dart'; // Make sure this path is correct
import'InformationPages/driver_information.dart';
import 'Profiles/driver_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passenger Info Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true, // Optional: for newer Material design
      ),
      home: const DriverProfile(),
    );
  }
}
