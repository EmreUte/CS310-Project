import 'package:flutter/material.dart';

class FindYourRidePage extends StatelessWidget {
  const FindYourRidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Your Ride"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Find Your Ride content goes here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
