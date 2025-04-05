import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';

class CreditCard {
  String name;
  String number;
  bool type; // true for Mastercard, false for Visa

  CreditCard({required this.name, required this.number, required this.type});
}

class CreditCardBlock extends StatelessWidget {
  final CreditCard card;
  final VoidCallback delete;
  final bool mode;

  const CreditCardBlock({super.key, required this.card, required this.delete, this.mode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 366,
      height: 72,
      margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
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
              card.type
                  ? 'assets/payment_related/mastercard_icon.png'
                  : 'assets/payment_related/visa_icon.png',
              width: 61,
              height: 61,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: kFillerText,
                ),
                Text(
                  card.number,
                  style: kFillerTextSmall,
                ),
              ],
            ),
            Spacer(),
            if (mode)
              IconButton(
                onPressed: delete,
                icon: Icon(
                  Icons.delete,
                  color: Colors.black,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
