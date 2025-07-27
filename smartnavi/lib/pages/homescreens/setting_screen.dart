import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartnavi/utils/router.gr.dart';
import 'package:smartnavi/services/firestore_service.dart'; // Import FirestoreService

@RoutePage()
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService(); // Add FirestoreService instance

  // App preferences state
  bool _notificationsEnabled = true; // Renamed variable
  
  // Notification status related variables
  String _notificationPermission = 'unknown';
  bool _isLoadingNotificationStatus = false;
  bool _isUpdatingNotification = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings(); // Load notification settings
  }

  @override
  void dispose() {
    _firestoreService.dispose(); // Cleanup resources
    super.dispose();
  }

  // Load notification settings
  void _loadNotificationSettings() async {
    setState(() {
      _isLoadingNotificationStatus = true;
    });

    try {
      // Get app-level notification setting
      final appEnabled = await _firestoreService.getNotificationEnabled();
      
      // Get browser permission status
      final permission = await _firestoreService.getNotificationPermission();
      
      setState(() {
        _notificationsEnabled = appEnabled;
        _notificationPermission = permission;
        _isLoadingNotificationStatus = false;
      });
      
      print('[Settings] Loaded notification settings - App: $appEnabled, Permission: $permission');
      
    } catch (e) {
      print('[Settings] Error loading notification settings: $e');
      setState(() {
        _isLoadingNotificationStatus = false;
      });
    }
  }

  // Handle notification toggle switch
  void _handleNotificationToggle(bool value) async {
    if (_isUpdatingNotification) return; // Prevent duplicate operations

    if (value && _notificationPermission != 'granted') {
      // User wants to enable notifications but browser permission not granted
      _showPermissionDialog();
      return;
    }

    setState(() {
      _isUpdatingNotification = true;
    });

    try {
      // Update app-level notification setting
      await _firestoreService.setNotificationEnabled(value);
      
      setState(() {
        _notificationsEnabled = value;
        _isUpdatingNotification = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Schedule notifications enabled'
                : 'Schedule notifications disabled',
          ),
          backgroundColor: value ? Colors.green : Colors.grey,
        ),
      );
      
      print('Notification setting updated: $value');
      
    } catch (e) {
      print('Error updating notification setting: $e');
      
      setState(() {
        _isUpdatingNotification = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update notification setting'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show permission request dialog
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To enable notifications, you need to:'),
            const SizedBox(height: 8),
            const Text('1. Grant permission to this website'),
            const Text('2. Allow notifications in your browser'),
            const SizedBox(height: 16),
            if (_notificationPermission == 'denied')
              const Text(
                'Permission was previously denied. You may need to reset it in your browser settings.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (_notificationPermission != 'denied')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _requestNotificationPermission();
              },
              child: const Text('Grant Permission'),
            ),
        ],
      ),
    );
  }

  // Request notification permission
  void _requestNotificationPermission() async {
    setState(() {
      _isUpdatingNotification = true;
    });

    try {
      final permission = await _firestoreService.requestNotificationPermission();
      
      setState(() {
        _notificationPermission = permission;
        _isUpdatingNotification = false;
      });

      if (permission == 'granted') {
        // Auto-enable notifications after permission is granted
        await _firestoreService.setNotificationEnabled(true);
        setState(() {
          _notificationsEnabled = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission granted! Notifications are now enabled.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission was denied'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
      
      setState(() {
        _isUpdatingNotification = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to request notification permission'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // Get notification status display text
  String _getNotificationStatusText() {
    if (_isLoadingNotificationStatus || _isUpdatingNotification) {
      return 'Updating...';
    }
    
    switch (_notificationPermission) {
      case 'granted':
        return _notificationsEnabled ? 'Enabled' : 'Disabled in app';
      case 'denied':
        return 'Blocked by browser';
      case 'default':
        return 'Permission not requested';
      default:
        return 'Unknown status';
    }
  }

  // Get notification status color
  Color _getNotificationStatusColor() {
    if (_isLoadingNotificationStatus || _isUpdatingNotification) {
      return Colors.grey;
    }
    
    switch (_notificationPermission) {
      case 'granted':
        return _notificationsEnabled ? Colors.green : Colors.orange;
      case 'denied':
        return Colors.red;
      case 'default':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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

          // Enhanced notification settings
          SwitchListTile(
            secondary: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_isLoadingNotificationStatus || _isUpdatingNotification)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
            title: const Text('Schedule Notifications'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Get notified when events are approaching'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getNotificationStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getNotificationStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getNotificationStatusColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            value: _notificationsEnabled && _notificationPermission == 'granted',
            onChanged: (_isLoadingNotificationStatus || _isUpdatingNotification) 
                ? null 
                : _handleNotificationToggle,
          ),

          // Browser settings instructions (shown when permission is denied)
          if (_notificationPermission == 'denied')
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.orange),
              title: const Text('Enable Notifications in Browser'),
            ),
        ],
      ),
    );
  }
}
