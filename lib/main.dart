import 'package:flutter/material.dart';

import 'digital_payments/add_new_card.dart';
import 'digital_payments/digital_payments_page.dart';
import 'utils/colors.dart

void main() {
  runApp(MaterialApp(
      initialRoute: '/digital_payments_page',
      routes: {
        '/': (context) => CreditCardScreen(),
        '/digital_payments_page': (context) => CreditCardScreen(),
        '/add_new_payment' : (context) => AddNewCard()
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
