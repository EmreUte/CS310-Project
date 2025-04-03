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
          style: kAppBarText,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 80, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "My Cards",
                  style: kHeadingText,
                ),
                SizedBox(width: 8), // Add some spacing between text and icon
                Icon(
                  Icons.edit,
                  color: Colors.black, // Match your app's color scheme
                  size: 24, // Adjust size as needed
                ),
              ]
            ),
            SizedBox(height: 10),
            Container(
              width: 366,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.fillBox,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/mastercard_icon.png', // Path to your Mastercard icon
                      width: 61, // Adjust size as needed
                      height: 61,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 22),
            Container(
              width: 366,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.fillBox,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/mastercard_icon.png', // Path to your Mastercard icon
                      width: 61, // Adjust size as needed
                      height: 61,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 22),
            Container(
              width: 366,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.fillBox,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 6, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/visa_icon.png', // Path to your Mastercard icon
                      width: 61, // Adjust size as needed
                      height: 61,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}