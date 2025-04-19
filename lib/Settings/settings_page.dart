import 'package:cs310_project/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

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
          _navTile('Personal information'),
          _navTile('Request account info'),
          _navTile('Delete account'),

          // Notifications
          _sectionHeader('Notifications'),
          SwitchListTile(
            title: Text('Show notifications'),
            value: _showNotifications,
            onChanged: (v) => setState(() => _showNotifications = v),
          ),
          SwitchListTile(
            title: Text('Sound'),
            value: _sound,
            onChanged: (v) => setState(() => _sound = v),
          ),

          // Language
          _sectionHeader('Language'),
          ListTile(
            title: Text('Language'),
            trailing: DropdownButton<String>(
              value: _language,
              underline: SizedBox(),
              onChanged: (val) => setState(() => _language = val!),
              items: ['English', 'Spanish', 'French']
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
                  .toList(),
            ),
          ),

          // Appearance
          _sectionHeader('Appearance'),
          SwitchListTile(
            title: Text('Dark theme'),
            value: _darkTheme,
            onChanged: (v) => setState(() => _darkTheme = v),
          ),
          ListTile(
            title: Text('Text size'),
            trailing: DropdownButton<String>(
              value: _textSize,
              underline: SizedBox(),
              onChanged: (val) => setState(() => _textSize = val!),
              items: ['Small', 'Medium', 'Large']
                  .map((size) => DropdownMenuItem(
                value: size,
                child: Text(size),
              ))
                  .toList(),
            ),
          ),

          // Help & Share
          _sectionHeader('Get Help'),
          _navTile('Help Page'),
          _sectionHeader('Share and rate'),
          _navTile('Share the app'),
          _navTile('Rate the app'),

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

  Widget _navTile(String title, [Function()? onTap]) {
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
          )
        ),
        trailing: Icon(Icons.play_arrow),
          onTap: onTap,
      )
    );
  }
}

