import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

class FindingRideScreen extends StatefulWidget {
  @override
  State<FindingRideScreen> createState() => _FindingRideScreenState();
}

class _FindingRideScreenState extends State<FindingRideScreen> {
  int _currentStep = 0;
  late Timer _timer;

  final List<String> steps = [
    "Searching for a Ride",
    "Matching Driver Found",
    "Driver is on the way",
    "Driver is close by",
    "Driver has arrived",
  ];

  @override
  void initState() {
    super.initState();
    _startProgressAnimation();
  }

  void _startProgressAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentStep < steps.length - 1) {
        setState(() {
          _currentStep++;
        });
      } else {
        _timer.cancel(); // Stop when finished
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color _getStepColor(int index) {
    if (index == _currentStep) {
      return Colors.lightGreenAccent;
    } else if (index < _currentStep) {
      return Colors.lightBlue.shade200;
    } else {
      return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Find Your Ride",
          style: TextStyle(color: AppColors.primaryText),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              separatorBuilder: (_, __) => Column(
                children: const [
                  Icon(Icons.arrow_downward, size: 30),
                  SizedBox(height: 8),
                ],
              ),
              itemBuilder: (context, index) {
                return Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: _getStepColor(index),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      steps[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.width * 0.15,
              child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      padding: Dimen.buttonPadding,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
              ),
            ),
                      onPressed: () {
                      // Cancel logic & return to the previous screen
                      _timer.cancel(); // Stop animation if user cancels
                      Navigator.pop(context);
                    },
                child: Center(
                      child: Text(
                              'Cancel',
                              style: kButtonText,
                      ),
                    ),
                  ),
                ),
              ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.10),
        ],
      ),
    );
  }
}
