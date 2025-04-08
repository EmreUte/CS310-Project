import 'package:cs310_project/help_related/faq_page.dart';
import 'package:cs310_project/help_related/help_page.dart';
import 'package:flutter/material.dart';

import 'digital_payments/add_new_card.dart';
import 'digital_payments/digital_payments_page.dart';
import 'package:cs310_project/utils/colors.dart';

void main() {
  runApp(MaterialApp(
      initialRoute: '/help_page',
      routes: {
        '/': (context) => CreditCardScreen(),
        '/digital_payments_page': (context) => CreditCardScreen(),
        '/add_new_payment' : (context) => AddNewCard(),
        '/help_page' : (context) => HelpScreen(),
        '/faq_page' : (context) => FaqScreen()
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.appBarBackground,
            elevation: 0.0,
            centerTitle: true,
          )
      )
  ),
  );
}
