import 'package:cs310_project/help_related/components/faq_block.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

class FaqScreen extends StatelessWidget {
  static const List<String> questions = [
    "How can I find a ride?",
    "How is the matching between driver and passengers done?",
    "Which one of my credit cards is used during payment?",
    "Can I use cash?",
  ];

  static const List<String> answers = [
    "After adjusting your preferences from the main profile page, you press the 'Find Your Ride!' button which will match you with the most optimal available driver!",
    "The algorithm takes into account the preferences of both the driver and the passenger to compute your compatibility. Afterwards, the best match is displayed.",
    "The app uses the top most credit card for payment, which can be found inside your Wallet. Currently, the only way of changing this order is through rearranging via deletion and adding.",
    "The use of cash must be discussed with your driver, since the app only allows online transactions to occur.",
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
                  children: questions.asMap().entries.map((entry) {
                    int index = entry.key;
                    String question = entry.value;
                    String answer = answers[index];
                    return QuestionBlock(
                      question: question,
                      answer: answer,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}