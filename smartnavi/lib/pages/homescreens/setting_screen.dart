import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnavi/utils/router.gr.dart';

@RoutePage()
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // App preferences state
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  bool _busNotifications = true;
  bool _addToiOSWidget = false;

  @override
  void initState() {
    super.initState();
  }

  void _signOut() async {
    await _auth.signOut();
    if (mounted) {
      context.router.replace(AuthRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // User Profile Section
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
            title: Text(user?.email ?? 'No email'),
            subtitle: const Text('Tap to edit profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to profile edit page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile edit not implemented')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _signOut();
                      },
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),

          // App Preferences Section
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Theme Toggle
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme switching not implemented'),
                ),
              );
            },
          ),

          // Language Selection
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: const Text('English'),
                        value: 'English',
                        groupValue: _selectedLanguage,
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('中文'),
                        value: '中文',
                        groupValue: _selectedLanguage,
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Bus Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Bus Arrival Notifications'),
            subtitle: const Text('Get notified when bus is approaching'),
            value: _busNotifications,
            onChanged: (value) {
              setState(() {
                _busNotifications = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Bus notifications enabled'
                        : 'Bus notifications disabled',
                  ),
                ),
              );
            },
          ),

          // iOS Widget
          SwitchListTile(
            secondary: const Icon(Icons.widgets),
            title: const Text('iOS Home Screen Widget'),
            subtitle: const Text('Add SmartNavi widget to iOS home screen'),
            value: _addToiOSWidget,
            onChanged: (value) {
              setState(() {
                _addToiOSWidget = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Widget will be added to home screen'
                        : 'Widget removed from home screen',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
