import 'package:flutter/material.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride History"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Ride History content goes here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
