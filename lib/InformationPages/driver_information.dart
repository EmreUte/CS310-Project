import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
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
  bool _isLoading = true;
  final DatabaseService _databaseService = DatabaseService();

  bool _isEditable = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot? userData = await _databaseService.getUserData();
      if (userData != null && userData.exists) {
        setState(() {
          _nameController.text = userData.get('name') ?? '';
          _emailController.text = userData.get('email') ?? '';
          _phoneController.text = userData.get('phone') ?? '';
          _plateController.text = userData.get('plateNumber') ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    try {
      await _databaseService.updateUserData(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        plateNumber: _plateController.text,
      );

      if (_passwordController.text.isNotEmpty) {
        await _databaseService.updatePassword(_passwordController.text);
        _passwordController.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating information: $e')),
      );
    }
  }


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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'E-mail',
                  controller: _emailController,
                  icon: Icons.email,
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'Phone',
                  controller: _phoneController,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'Password',
                  controller: _passwordController,
                  icon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 22),
                _buildInputField(
                  label: 'Plate Number',
                  controller: _plateController,
                  isPassword: true,
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
                            _saveUserData();
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: _isEditable,
        obscureText: isPassword,
        autocorrect: !isPassword,
        enableSuggestions: !isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.secondaryText),
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.secondaryText)
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
        style: const TextStyle(color: AppColors.secondaryText),


        validator: (value) {
          if (value == null || value.isEmpty) {
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