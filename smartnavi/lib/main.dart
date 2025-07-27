import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartnavi/utils/theme.dart';
import 'firebase_options.dart';
import 'utils/router.dart';
import 'utils/router.gr.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  
  /// Set up notification click listener for web
  void _setupNotificationListener() {
    if (kIsWeb) {
      // Listen for notification click events
      web.document.addEventListener('notificationClicked', (web.Event event) {
        final customEvent = event as web.CustomEvent;
        final detail = customEvent.detail;
        
        print('Received notification clicking event: $detail');
        
        // Handle the notification click
        _handleNotificationClick(detail);
      }.toJS);
      
      print('Notification click listener set up for web');
    }
  }
  
  /// Handle notification click events
  void _handleNotificationClick(dynamic detail) {
    try {
      // Extract notification details
      final notificationId = detail['id']?.toString() ?? '';
      final title = detail['title']?.toString() ?? '';
      
      print('处理通知点击: ID=$notificationId, Title=$title');
      
      // Jump to different pages based on notification ID
      if (notificationId.contains('urgent_') || notificationId.contains('reminder_')) {
        // Jump to schedule page
        _navigateToSchedule();
      } else if (notificationId.contains('welcome') || notificationId.contains('test')) {
        // Jump to home page
        _navigateToHome();
      } else {
        // Default action: jump to schedule page
        _navigateToSchedule();
      }
      
    } catch (e) {
      print('Failed to handle notification clicking: $e');
      _navigateToSchedule();
    }
  }
  
  /// Navigate to schedule page
  void _navigateToSchedule() {
    try {
      _appRouter.replaceAll([ScheduleRoute()]);
      
      print('Jumped to schedule page');
    } catch (e) {
      print('Failed to jump to schedule page: $e');
    }
  }
  
  /// Navigate to home page
  void _navigateToHome() {
    try {
      _appRouter.replaceAll([NavigationRoute()]);
      print('Jumped to home page');
    } catch (e) {
      print('Failed to jump to home page: $e');
    }
  }
  
  /// Initialize notification service
  void _initializeNotifications() async {
    try {
      final success = await _firestoreService.initializeNotifications();
      
      if (success) {
        print('Initialized notification service successfully');
        
      } else {
        print('Failed to initialize notification service');
      }
    } catch (e) {
      print('Error in initializing notification service: $e');
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
}

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.config(),
    );
  }

