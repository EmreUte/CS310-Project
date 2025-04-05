import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

import 'add_new_card.dart';
import 'components/credit_card.dart';

class CreditCardScreen extends StatefulWidget {
  const CreditCardScreen({super.key});

  @override
  State<CreditCardScreen> createState() => _CreditCardScreenState();
}

class _CreditCardScreenState extends State<CreditCardScreen> {
  bool inEdit = false;
  List<CreditCard> cards = [
    CreditCard(name: "Cenker Şahin Main Card", number: "12491************43", type: true),
    CreditCard(name: "Emre Üte Main Card", number: "42813************71", type: true),
    CreditCard(name: "Emre Üte Visa", number: "14834************14", type: false),
  ];

  void editMode() {
    setState(() {
      inEdit = !inEdit;
    });
  }
  void deleteCard (CreditCard card) {
    setState(() {
      cards.remove(card);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Digital Payments",
          style: kAppBarText,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: Dimen.screenPadding,
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
                IconButton(
                  onPressed: () {editMode();},
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Column(
              children: cards.map((card) => CreditCardBlock(
                card: card,
                mode: inEdit,
                delete: () {
                  deleteCard(card);
                  },
                )
              ).toList(),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddNewCard()),
                      );
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 28,
                    ),
                    label: Text(
                      "Add a new card",
                      style: kHeadingText,
                    ),
                  ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Text(
                  "Other Methods",
                  style: kHeadingText,
                ),
              ],
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
                      width: 93,
                      height: 62,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      'assets/payment_related/paypal_icon.png',
                      width: 135,
                      height: 44,
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