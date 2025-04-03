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
        padding: EdgeInsets.fromLTRB(30, 60, 30, 80),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/payment_related/mastercard_icon.png',
                      width: 61, // Adjust size as needed
                      height: 61,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cenker Şahin Main Card",
                          style: kFillerText,
                        ),
                        Text(
                          "12491************43",
                          style: kFillerTextSmall,
                        ),
                      ],
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/payment_related/mastercard_icon.png',
                      width: 61, // Adjust size as needed
                      height: 61,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Emre Üte Main Card",
                          style: kFillerText,
                        ),
                        Text(
                          "42813************71",
                          style: kFillerTextSmall,
                        ),
                      ],
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/payment_related/visa_icon.png',
                      width: 61, // Adjust size as needed
                      height: 61,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Emre Üte Visa",
                          style: kFillerText,
                        ),
                        Text(
                          "14834************14",
                          style: kFillerTextSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.black, // Match your app's color scheme
                    size: 24, // Adjust size as needed
                  ),
                  SizedBox(width: 20), // Add some spacing between text and icon
                  Text(
                    "Add a new card",
                    style: kHeadingText,
                  ),
                ]
            ),



            Spacer(), // Pushes "Other Methods" to the bottom
            Row(
                children: [
                  Text(
                    "Other Methods",
                    style: kHeadingText,
                  ),
                ]
            ),
            SizedBox(height: 10),
            Container(
              width: 366,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.fillBox,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/payment_related/apple_pay_icon.png',
                      width: 93, // Adjust size as needed
                      height: 62,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      'assets/payment_related/paypal_icon.png',
                      width: 135, // Adjust size as needed
                      height: 44,
                      fit: BoxFit.contain,
                    )
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