import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartnavi/utils/theme.dart';
import 'firebase_options.dart';
import 'utils/router.dart';
import 'utils/router.gr.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:smartnavi/services/firestore_service.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

final _appRouter = AppRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _firestoreService = FirestoreService();
  
  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
    _initializeNotifications();
  }
  
  /// Set up notification click listener for web platform
  void _setupNotificationListener() {
    if (kIsWeb) {
      web.document.addEventListener('notificationClicked', (web.Event event) {
        try {
          final customEvent = event as web.CustomEvent;
          final detail = customEvent.detail;
          
          _debugLog('Received notification click event: $detail');
          
          // Use dartify() method to handle JavaScript object
          _handleNotificationClick(detail);
          
        } catch (e) {
          _errorLog('Failed to listen for notification event: $e');
        }
      }.toJS);
      
      _debugLog('Notification click listener has been set up successfully');
    }
  }
  
  /// Handle notification click using dartify() to convert JS object to Dart
  void _handleNotificationClick(JSAny? detail) {
    try {
      _debugLog('Starting to handle notification click event...');
      
      if (detail == null) {
        _errorLog('Notification detail is null');
        _navigateToHome();
        return;
      }
      
      // Convert JavaScript object to Dart object using dartify()
      final dartDetail = detail.dartify();
      _debugLog('Converted detail: $dartDetail');
      
      String notificationId = '';
      String title = '';
      String body = '';
      
      // Handle the converted Dart object
      if (dartDetail is Map<String, dynamic>) {
        notificationId = dartDetail['id']?.toString() ?? '';
        title = dartDetail['title']?.toString() ?? '';
        body = dartDetail['body']?.toString() ?? '';
        
        _debugLog('Parsed notification - ID: $notificationId, Title: $title');
        
      } else {
        // Fallback: try to parse as string
        final detailStr = dartDetail.toString();
        _debugLog('Fallback string parsing: $detailStr');
        
        // Extract information from string representation
        if (detailStr.contains('reminder_') || detailStr.contains('urgent_')) {
          notificationId = 'reminder_fallback';
          title = 'Course Reminder';
        } else if (detailStr.contains('welcome') || detailStr.contains('test')) {
          notificationId = 'welcome_fallback';
          title = 'Welcome Message';
        } else {
          notificationId = 'unknown_fallback';
          title = 'Unknown Notification';
        }
      }
      
      // Route based on notification type
      _routeBasedOnNotification(notificationId, title);
      
    } catch (e) {
      _errorLog('Failed to handle notification click: $e');
      _navigateToHome(); // Safe fallback when error occurs
    }
  }
  
  /// Unified routing logic based on notification type
  void _routeBasedOnNotification(String notificationId, String title) {
    _debugLog('Routing notification: ID=$notificationId, Title=$title');
    
    if (notificationId.contains('urgent_') || 
        notificationId.contains('reminder_') ||
        notificationId.contains('schedule')) {
      // Course-related notifications - Navigate to schedule page
      _navigateToSchedule();
    } else if (notificationId.contains('welcome') || 
               notificationId.contains('test') ||
               notificationId.contains('button_test')) {
      // Welcome/test notifications - Navigate to home page
      _navigateToHome();
    } else {
      // Default behavior - Navigate to schedule page
      _debugLog('Unknown notification type, navigating to schedule page');
      _navigateToSchedule();
    }
  }
  
  /// Navigate to schedule page
  void _navigateToSchedule() {
    try {
      _appRouter.replaceAll([ScheduleRoute()]);
      _debugLog('SUCCESS: Successfully navigated to schedule page');
    } catch (e) {
      _errorLog('Failed to navigate to schedule page: $e');
    }
  }
  
  /// Navigate to home page  
  void _navigateToHome() {
    try {
      _appRouter.replaceAll([NavigationRoute()]);
      _debugLog('SUCCESS: Successfully navigated to home page');
    } catch (e) {
      _errorLog('Failed to navigate to home page: $e');
    }
  }
  
  /// Initialize notification service
  void _initializeNotifications() async {
    try {
      _debugLog('Starting to initialize notification service...');
      final success = await _firestoreService.initializeNotifications();
      
      if (success) {
        _debugLog('SUCCESS: Notification service initialized successfully');
      } else {
        _debugLog('FAILED: Failed to initialize notification service');
      }
    } catch (e) {
      _errorLog('Error occurred while initializing notification service: $e');
    }
  }
  
  @override
  void dispose() {
    _firestoreService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SmartNavi', 
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.config(),
    );
  }
  
  /// Debug logging method
  void _debugLog(String message) {
    if (kDebugMode) {
      print('[SmartNavi Debug] $message');
    }
  }
  
  /// Error logging method
  void _errorLog(String message) {
    print('[SmartNavi Error] $message');
  }
}
