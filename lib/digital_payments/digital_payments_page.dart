import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Digital Payments",
          style: kHeadingTextStyle,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 80, 20, 0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
        Container(
          width: double.infinity, // Makes it span the available width
            height: 100, // Adjust height for "long box" feel
            decoration: BoxDecoration(
              color: AppColors.fillBox, // Using a color from your utils
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                child: Text(
                  "Cenker Şahin",
                  style: TextStyle(
                    color: AppColors.secondaryText, // Contrast with background
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}