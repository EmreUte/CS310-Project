import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

class QuestionScreen extends StatelessWidget {
  final String question;
  final String answer;

  const QuestionScreen(this.question, this.answer, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: AutoSizeText(
          question,
          style: kAppBarText,
          maxLines: 1,
          minFontSize: 12, // Minimum font size to ensure readability
          maxFontSize: kAppBarText.fontSize?.toDouble() ?? 24, // Use kAppBarText font size as max
          overflow: TextOverflow.ellipsis, // Fallback if text still doesn't fit
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
      body: Padding(
          padding: Dimen.screenPadding,
          child: Text(
            answer,
            style: kText,
          ),
      ),
    );
  }

}