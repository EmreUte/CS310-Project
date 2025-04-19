import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import 'faq_page.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Help",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 366,
              height: 72,
              margin: Dimen.cardMargins,
              decoration: BoxDecoration(
                color: AppColors.fillBox,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FaqScreen()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.mood,
                      color: Colors.black,
                      size: 33,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "FAQ",
                          style: kHeadingText,
                        ),
                      ),
                    ),
                    SizedBox(width: 33), // Invisible space to balance the icon's width
                  ],
                ),
              ),
            ),
            Container(
              width: 366,
              height: 72,
              margin: Dimen.cardMargins,
              decoration: BoxDecoration(
                color: AppColors.fillBox,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () { /*
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpScreen()),
                  );
                  */
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.mail,
                      color: Colors.black,
                      size: 33,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Contact Us",
                          style: kHeadingText,
                        ),
                      ),
                    ),
                    SizedBox(width: 33), // Invisible space to balance the icon's width
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}