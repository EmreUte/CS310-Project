import 'dart:io';

import 'package:cs310_project/models/user_model.dart';
import 'package:cs310_project/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  String msg = "";

  // Show a dialog for errors or confirmation
  Future<void> _showDialog(String title, String message) async {
    bool isAndroid = Platform.isAndroid;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (isAndroid) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        } else {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Contact Us",
          style: kAppBarText,
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: Dimen.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Support will get back to you in at most 24 hours. Please do not spam messages.",
                style: kText,
                softWrap: true,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "Enter your message.",
                            filled: true,
                            fillColor: AppColors.fillBox,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: Dimen.textboxPadding,
                            errorMaxLines: 2,
                            hintMaxLines: 2,
                          ),
                          maxLines: 7,
                          keyboardType: TextInputType.multiline,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a message';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            msg = value ?? '';
                          },
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 222,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {

                                  _formKey.currentState!.save();

                                  DatabaseService(uid: user.uid).sendMessage(msg);

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Message submitted')),
                                  );



                                } else {
                                  _showDialog(
                                    'Form Error',
                                    'Please enter a valid message.',
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonBackground,
                                padding: Dimen.buttonPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: kButtonText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Phone:",
                    style: kText,
                  ),
                  Text(
                    "+90 533 412 59 83",
                    style: kText,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Email:",
                    style: kText,
                  ),
                  Text(
                    "myride@info.tr",
                    style: kText,
                    textAlign: TextAlign.right,
                  ),
                ],
              )
            ],
          ),
        ),
    );
  }
}