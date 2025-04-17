import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: Text(
          'Settings Page Coming Soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
