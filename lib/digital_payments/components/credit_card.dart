import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';
import '../../utils/dimensions.dart';

class CreditCard {
  String cid;
  String name;
  String number;
  String month;
  String year;
  bool type; // true for Mastercard, false for Visa

  Map<String, dynamic> toMap() => {
    'id': cid,
    'name': name,
    'number': number,
    'month': month,
    'year': year,
    'type': type
  };

  CreditCard({required this.cid, required this.name, required this.number,
              required this.month, required this.year, required this.type});
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
      margin: Dimen.cardMargins,
      decoration: BoxDecoration(
        color: AppColors.fillBox,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
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
