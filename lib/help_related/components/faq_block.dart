import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';
import '../../utils/dimensions.dart';
import '../questions_page.dart';

class QuestionBlock extends StatelessWidget {
  final String question;

  const QuestionBlock({super.key, required this.question});

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
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionScreen(question),
              ),
            );
          },
          child: Row(
            children: [
              Flexible(
                child: Text(
                  question,
                  style: kFillerText,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}