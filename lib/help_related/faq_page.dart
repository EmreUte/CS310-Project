import 'package:cs310_project/help_related/components/faq_block.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

class FaqScreen extends StatelessWidget {
  static const List<String> questions = [
    "How can I find a ride?",
    "How is the matching between driver and passengers done?",
    "Can I use cash?",  // Added missing comma here
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
    "...",
  ];

  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "FAQ",
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
      body: Padding(
        padding: Dimen.screenPadding,
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: questions.map((question) => QuestionBlock(
                      question: question
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}