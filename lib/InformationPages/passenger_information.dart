import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../Settings/settings_page.dart';
import '../utils/dimensions.dart';
import '../utils/styles.dart';
import '../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PassengerInformationScreen extends StatefulWidget {
  const PassengerInformationScreen({super.key});

  @override
  State<PassengerInformationScreen> createState() =>
      _PassengerInformationScreenState();
}

class _PassengerInformationScreenState
    extends State<PassengerInformationScreen> {
  bool _isLoading = true;
  final DatabaseService _databaseService = DatabaseService();


  bool _isEditable = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Passenger Information',
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
                const SizedBox(height: 40),
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
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), // width!
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
    required IconData icon,
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
        style: TextStyle(
          color: _isEditable && isEditable ? Colors.black : Colors.grey,
        ),

        decoration: InputDecoration(

          label: SizedBox(
            width: 180,
            child: Row(
              children: [
// Update the Icon in the label Row
                Icon(
                  icon,
                  color: _isEditable && isEditable ? Colors.black : Colors.grey,
                ),
                const SizedBox(width: 8),
// Update the Text in the label Row
                Text(
                  label,
                  style: TextStyle(
                    color: _isEditable && isEditable ? Colors.black : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
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
        // In the _buildInputField method, replace the validator with:
        validator: (value) {
          if (value == null || value.isEmpty) {
            // Make password field optional
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
