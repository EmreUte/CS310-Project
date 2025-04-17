import 'package:flutter/material.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preferences"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Preferences content goes here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
