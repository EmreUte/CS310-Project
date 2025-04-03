import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';

class AddNewCard extends StatefulWidget {
  const AddNewCard({super.key});

  @override
  State<AddNewCard> createState() => _AddNewCardState();
}

class _AddNewCardState extends State<AddNewCard> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            'Enter Card Info',
            style: kAppBarText,
          ),
        ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(30, 60, 30, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              _buildInputField(
                label: 'Card Name',
                hint: 'Enter card holder name',
              ),
              SizedBox(height: 22),
              _buildInputField(
                label: 'Card Number',
                hint: 'Enter card number',
              ),
              SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'Month',
                      hint: 'MM',
                    ),
                  ),
                  SizedBox(width: 26),
                  Expanded(
                    child: _buildInputField(
                      label: 'Year',
                      hint: 'YY',
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
                      // I will define function here after database implementation
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonBackground,
                      padding: EdgeInsets.symmetric(vertical: 14),
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
              SizedBox(height: 40),
            ],
          ),
        ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: kFillerText,
          ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
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
        ),
      ],
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
          activeColor: AppColors.buttonBackground,
        ),
        const Text(
          'I agree to the Terms & Conditions',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}