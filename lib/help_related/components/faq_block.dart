import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../utils/styles.dart';
import '../../utils/dimensions.dart';

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
        child: Row(
          children: [
          Flexible(  // Added Flexible widget
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
    );
  }
}