import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/styles.dart';

class QuestionScreen extends StatelessWidget {
  final String question;

  const QuestionScreen(this.question, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
          question,
          style: kAppBarText,
      ),
      leading: IconButton(
      icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
      onPressed: () => {
        Navigator.pop(context)
      },
      ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
    );
  }

}