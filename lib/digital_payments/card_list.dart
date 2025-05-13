import 'package:cs310_project/digital_payments/components/credit_card.dart';
import 'package:cs310_project/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import 'add_new_card.dart';

class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  State<CardList> createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  bool inEdit = false;

  void editMode() {
    setState(() {
      inEdit = !inEdit;
    });
  }
  @override
  Widget build(BuildContext context) {
    final List<CreditCard>? cards = Provider.of<List<CreditCard>?>(context);
    final user = Provider.of<MyUser>(context);
    final dbService = DatabaseService(uid: user.uid);
    return Padding(
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
          if (cards != null)
            Column(
              children: cards.map((card) => CreditCardBlock(
                card: card,
                mode: inEdit,
                delete: () {
                  dbService.removeCreditCard(card.id);
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
                    MaterialPageRoute(
                      builder: (context) => StreamProvider<UserModel?>.value(
                      value: dbService.userData,
                      initialData: null,
                      child: AddNewCard(),
                      ),
                    )
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
    );
  }
}