import 'package:cs310_project/Profiles/driver_profile.dart';
import 'package:cs310_project/Profiles/passenger_profile.dart';
import 'package:cs310_project/digital_payments/digital_payments_page.dart';
import 'package:cs310_project/screens/welcome_page.dart';
import 'package:cs310_project/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'error_page.dart';
import 'models/user_model.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser?>(context);
    if (user == null) {
      // Return Home or Authenticate
      return WelcomePage();
    }
    else {
      return PassengerProfile();
    }
  }
}