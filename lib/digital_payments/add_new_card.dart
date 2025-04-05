import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'dart:io' show Platform;

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';


class AddNewCard extends StatefulWidget {
  const AddNewCard({super.key});

  @override
  State<AddNewCard> createState() => _AddNewCardState();
}

class _AddNewCardState extends State<AddNewCard> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = "";
  String cardName = "";
  String cardMonth = "";
  String cardYear = "";
  bool hasSubmitted = false;

  Future<void> _showDialog(String title, String message) async {
    bool isAndroid = Platform.isAndroid;
    return showDialog(context: context, builder: (BuildContext context) {
          if (isAndroid) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                },
                    child: Text('OK')
                )
              ],
            );
          }
          else {
            return CupertinoAlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(onPressed: () {
                  Navigator.of(context).pop();
                },
                    child: Text('OK')
                )
              ],
            );
          }
        }
        );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            'Enter Card Info',
            style: kAppBarText,
          ),
        ),
      body: Padding(
          padding: Dimen.screenPadding,
          child:  Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                      "Card Name",
                      style: kFillerText,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Enter card holder name",
                        filled: true,
                        fillColor: AppColors.fillBox,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),

                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return 'REQUIRED FIELD';
                          }
                        }
                        return null;
                      },
                      onSaved: (value) {
                        cardName = value ?? '';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 22),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Card Number",
                      style: kFillerText,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Enter card number",
                        filled: true,
                        fillColor: AppColors.fillBox,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: Dimen.textboxPadding
                      ),

                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return 'REQUIRED FIELD';
                          }
                          else if (value.length != 16) {
                            return 'Invalid card number';
                          }
                        }
                        return null;
                      },
                      onSaved: (value) {
                        cardNumber = value ?? '';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Month",
                            style: kFillerText,
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "MM",
                              filled: true,
                              fillColor: AppColors.fillBox,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: Dimen.textboxPadding
                            ),

                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'REQUIRED FIELD';
                                }
                                else if (value.length > 2) {
                                  return 'Invalid month';
                                }
                              }
                              return null;
                            },
                            onSaved: (value) {
                              cardMonth = value ?? '';
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 26),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Year",
                            style: kFillerText,
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "YY",
                              filled: true,
                              fillColor: AppColors.fillBox,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: Dimen.textboxPadding
                            ),

                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return 'REQUIRED FIELD';
                                }
                                else if (value.length > 4) {
                                  return 'Invalid year';
                                }
                              }
                              return null;
                            },
                            onSaved: (value) {
                              cardYear = value ?? '';
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 22),
                _buildTermsAndConditions(),
                SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 222,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          hasSubmitted = true; // Set flag when button is clicked
                        });
                        if (_formKey.currentState!.validate() && tickVal == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          _formKey.currentState!.save();
                        } else {
                          String errorMessage = 'Try again with valid card information';
                          if (tickVal == false) {
                            errorMessage = 'Try again with valid card information and agree to the Terms & Conditions';
                          }
                          _showDialog('Form Error', errorMessage);
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
                        'Add Card',
                        style: kButtonText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  bool tickVal = false;
  void addTick() {
    setState(() {
      tickVal = !tickVal;
    });
  }
  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: tickVal,
          onChanged: (value) {
            addTick();
          },
          activeColor: AppColors.checkbox,
        ),
        Text(
          'I agree to the Terms & Conditions',
          style: TextStyle(
            fontSize: 14,
            color: (hasSubmitted && !tickVal) == false ? Colors.black : Colors.red,
          ),
        ),
      ],
    );
  }
}