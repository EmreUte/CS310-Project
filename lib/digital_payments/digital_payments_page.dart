import 'package:cs310_project/digital_payments/card_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

import 'add_new_card.dart';
import 'components/credit_card.dart';
import '../services/database.dart';

class CreditCardScreen extends StatelessWidget {

  const CreditCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    return StreamProvider<List<CreditCard>?>.value(
        value: DatabaseService(uid: user.uid).cards,
        initialData: null,
        child: Scaffold(
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
          body: CardList()
        )
    );
  }
}