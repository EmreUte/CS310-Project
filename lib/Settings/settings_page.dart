import 'package:cs310_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/welcome_page.dart';
import '../services/auth.dart';
import '../utils/colors.dart';
import '../services/database.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  bool _showNotifications = true;
  bool _sound = true;
  bool _darkTheme = false;
  String _language = 'English';
  String _textSize = 'Medium';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: Text(
            'Settings',
            style: kAppBarText),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_outlined, size: 33, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Account Section
          _sectionHeader('Account'),
          _settingsTile(
              'Personal information',
              Icon(Icons.play_arrow),
                  () {
                final myUser = Provider.of<MyUser?>(context, listen: false);
                if (myUser != null) {
                  final dbService = DatabaseService(uid: myUser.uid);
                  dbService.userData.first.then((userData) {

                    if (userData != null) {
                      if (userData.userType == 'Driver') {
                        Navigator.pushNamed(context, '/driver_information');
                      } else {
                        Navigator.pushNamed(context, '/passenger_information');
                      }
                    }
                  });
                }
              }
          ),


          _settingsTile('Request account info', Icon(Icons.play_arrow)),
          _settingsTile(
            'Delete account',
            Icon(Icons.play_arrow),
            () => _showDeleteAccountDialog(context),
          ),

          // Notifications
          _sectionHeader('Notifications'),
          _settingsTile('Show notifications', Switch(
            value: _showNotifications,
            onChanged: (v) => setState(() => _showNotifications = v))),
          _settingsTile('Sound', Switch(
              value: _sound,
              onChanged: (v) => setState(() => _sound = v))),

          // Language
          _sectionHeader('Language'),
          _settingsTile('Language', DropdownButton<String>(
            value: _language,
            underline: SizedBox(),
            onChanged: (val) => setState(() => _language = val!),
            items: ['English', 'Spanish', 'French']
                .map((lang) => DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                ))
                .toList(),
          )),

          // Appearance
          _sectionHeader('Appearance'),
          _settingsTile('Dark theme', Switch(
              value: _darkTheme,
              onChanged: (v) => setState(() => _darkTheme = v))),
          _settingsTile('Text size', DropdownButton<String>(
            value: _textSize,
            underline: SizedBox(),
            onChanged: (val) => setState(() => _textSize = val!),
            items: ['Small', 'Medium', 'Large']
                .map((size) => DropdownMenuItem(
              value: size,
              child: Text(size),
            ))
                .toList(),
          )),

          // Help & Share
          _sectionHeader('Get Help'),
          _settingsTile('Help Page', Icon(Icons.play_arrow), () => Navigator.pushNamed(context, '/help_page')),
          _sectionHeader('Share and rate'),
          _settingsTile('Share the app', Icon(Icons.play_arrow)),
          _settingsTile('Rate the app', Icon(Icons.play_arrow)),

          // Log out button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF65558F),
                  shape: StadiumBorder(),
                  padding:
                  EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                ),
                onPressed: () {
                  AuthService().signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Text(
                  'Log out',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          color: Color(0xFFCAC4D0),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _settingsTile (
    String title,
    [Widget? trailing,
    Function()? onTap,]
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE6E0E9),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF49454F),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: Color(0xFF1D1B20),
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    final myUser = Provider.of<MyUser?>(context, listen: false);
    if (myUser == null) return;

    String password = '';
    String email = '';
    final userDoc = await DatabaseService(uid: myUser.uid).userCollection.doc(myUser.uid).get();
    if (userDoc.exists) {
      email = userDoc['email'] ?? '';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.',
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password to confirm',
                ),
                onChanged: (val) => password = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the confirmation dialog
                Navigator.of(dialogContext).pop();
                
                // Show a simple loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => PopScope(
                    canPop: false,  // This prevents the dialog from being dismissed
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
                
                try {
                  // Perform account deletion with navigation handled by the auth service
                  await AuthService().reauthenticateAndDeleteAccount(
                    uid: myUser.uid,
                    email: email,
                    password: password,
                    context: context, // Pass context for navigation
                  );
                } catch (e) {
                  // If we reach here, something went wrong
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: ${e.toString()}')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

}

