import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DriverInformationScreen extends StatefulWidget {
  const DriverInformationScreen({super.key});

  @override
  State<DriverInformationScreen> createState() =>
      _DriverInformationScreen();
}

class _DriverInformationScreen extends State<DriverInformationScreen>{
  bool _isEditable = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();



  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.appBarBackground,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          'Driver Information',
          style: kAppBarText,
        ),


      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildAvatar(),
                const SizedBox(height: 40),
                _buildInputField(
                  label: 'Name',
                  controller: _nameController,
                  icon: Icons.person,
                  isEditable: false,
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'E-mail',
                  controller: _emailController,
                  icon: Icons.email,
                  isEditable: false,
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'Phone',
                  controller: _phoneController,
                  icon: Icons.phone,
                  isEditable: true,
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'New Password?',
                  controller: _passwordController,
                  icon: Icons.lock,
                  isPassword: true,
                  isEditable: true,
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'Plate Number',
                  controller: _plateController,
                  isPassword: false,
                  isEditable: true,
                ),
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditable = !_isEditable;
                        if (!_isEditable) {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // _saveUserData();
                          } else {
                            // If validation fails, keep in edit mode
                            _isEditable = true;
                          }
                        }
                      });
                    },

                    style: ElevatedButton.styleFrom(

                      backgroundColor: AppColors.buttonBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14,),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isEditable ? 'Done' : 'Edit',
                      style:  kButtonText,

                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFFEADDFF),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Center(
        child: Icon(
          Icons.person_outline,
          size: 80,
          color: Color(0xFF4F378A),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool isPassword = false,
    bool isEditable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditable && isEditable,
        obscureText: isPassword,
        autocorrect: !isPassword,
        enableSuggestions: !isPassword,

        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: _isEditable && isEditable ? Colors.black : Colors.grey,
          ),
          prefixIcon: icon != null
              ? Icon(
            icon,
            color: _isEditable && isEditable ? Colors.black : Colors.grey,
          )
              : const SizedBox(width: 24),

          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(
          color: _isEditable && isEditable ? Colors.black : Colors.grey,
        ),


        validator: (value) {
          if (value == null || value.isEmpty) {
            if (isPassword) {
              return null;
            }
            return 'Please enter $label';
          }
          return null;
        },

        onSaved: (value) {

        },
      ),
    );
  }
}