import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

class FirestoreService {
  
  // Schedule related collections
  final CollectionReference _schedulesCollection = 
      FirebaseFirestore.instance.collection('schedules');

  // navigation related collections
  final CollectionReference _venuesCollection = 
      FirebaseFirestore.instance.collection('Venues');
      
  final CollectionReference _routesCollection = 
      FirebaseFirestore.instance.collection('Routes');
  
  // Schedule related methods
  // Get a stream of all schedules
  Stream<List<Schedule>> getSchedules() {
    return _schedulesCollection
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }

  // Add a new schedule
  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection.add(schedule.toFirestore());
    } catch (e) {
      throw Exception('Failed to add schedule: $e');
    }
  }

  // Update a schedule 
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _schedulesCollection.doc(schedule.id).update(schedule.toFirestore());
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete a schedule
  Future<void> deleteSchedule(String id) async {
    try {
      await _schedulesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      DocumentSnapshot doc = await _schedulesCollection.doc(scheduleId).get();
      if (doc.exists) {
        return Schedule.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get schedule: $e');
    }
  }

  // Get upcoming schedules
  Stream<List<Schedule>> getUpcomingSchedules() {
    return _schedulesCollection
        .where('eventDate', isGreaterThan: Timestamp.now())
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }

  // Get today's schedules
  Stream<List<Schedule>> getTodaySchedules() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return _schedulesCollection
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }

  // Navigation related methods
  // Get station names for autocomplete
  Future<List<String>> getStationNames() async {
    try {
      final snapshot = await _venuesCollection.get();
      // Map the documents to a list of names
      final stationNames = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['name'] as String)
          .toList();
      return stationNames;
    } catch (e) {
      print("Error fetching station names: $e");
      // Return an empty list in case of an error
      return [];
    }
  }

  // Search for a route between two stations
  Future<String?> searchRoute(String startStation, String endStation) async {
    if (startStation.trim().isEmpty || endStation.trim().isEmpty) {
      return "Please select a valid start and end station.";
    }
    
    final String docId = '${startStation.trim()}_${endStation.trim()}';
    
    try {
      final DocumentSnapshot routeDoc = await _routesCollection.doc(docId).get();
          
      if (routeDoc.exists) {
        final data = routeDoc.data() as Map<String, dynamic>?;
        return data?['Bus_name'] as String? ?? "Data format error";
      } else {
        return "No direct route found from $startStation to $endStation.";
      }
    } catch (e) {
      print("Error searching route: $e");
      return "Query failed. Please check your network connection and try again.";
    }
  }


  // ============== NOTIFICATION PROPERTIES ==============
  Timer? _notificationTimer;
  bool _notificationPermissionGranted = false;
  final Set<String> _scheduledNotificationIds = <String>{};


  /// Notification related methods
  /// Initialize notifications using modern Web API
  Future<bool> initializeNotifications() async {
    if (!kIsWeb) {
      print('Notifications: Not available on mobile platform');
      return false;
    }

    try {
      // Check if notifications are supported
      if (!_isNotificationSupported()) {
        print('Notifications: Browser does not support notifications');
        return false;
      }

      // Check current permission status
      String currentPermission = await _getCurrentPermission();
      print('Notifications: Current permission - $currentPermission');

      switch (currentPermission) {
        case 'granted':
          _notificationPermissionGranted = true;
          _startNotificationScheduler();
          print('Notifications: Permission already granted');
          return true;
          
        case 'denied':
          print('Notifications: Permission previously denied');
          return false;
          
        case 'default':
        default:
          // Request permission from the user
          String permission = await _requestPermission();
          _notificationPermissionGranted = (permission == 'granted');
          
          if (_notificationPermissionGranted) {
            _startNotificationScheduler();
            _sendWelcomeNotification();
            print('Notifications: Permission granted by user');
          } else {
            print('Notifications: Permission denied by user');
          }
          
          return _notificationPermissionGranted;
      }
      
    } catch (error) {
      print('Notifications: Initialization failed - $error');
      return false;
    }
  }

  /// Check if notification is supported using modern API
  bool _isNotificationSupported() {
    if (!kIsWeb) return false;
    
    try {
      return web.window.navigator.serviceWorker != null && 
             _checkNotificationAPI();
    } catch (e) {
      print('Error checking notification support: $e');
      return false;
    }
  }

  /// Check Notification API availability via JS interop
  bool _checkNotificationAPI() {
    try {
      return _jsHasNotification();
    } catch (e) {
      return false;
    }
  }

  /// Get current permission status using modern API
  Future<String> _getCurrentPermission() async {
    if (!kIsWeb) return 'denied';
    
    try {
      return _jsGetNotificationPermission();
    } catch (e) {
      print('Error getting notification permission: $e');
      return 'denied';
    }
  }

  /// Request notification permission using modern API
  Future<String> _requestPermission() async {
    if (!kIsWeb) return 'denied';
    
    try {
      return await _jsRequestNotificationPermission();
    } catch (e) {
      print('Error requesting notification permission: $e');
      return 'denied';
    }
  }

  /// Start notification scheduler
  void _startNotificationScheduler() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkAndSendUpcomingNotifications();
    });
    print('Notifications: Scheduler started');
  }

  /// Check and send upcoming notifications
  void _checkAndSendUpcomingNotifications() async {
    if (!_notificationPermissionGranted || !kIsWeb) return;

    try {
      final now = DateTime.now();
      final in20Minutes = now.add(Duration(minutes: 20));
      
      final snapshot = await _schedulesCollection
          .where('eventDate', isGreaterThan: Timestamp.fromDate(now))
          .where('eventDate', isLessThan: Timestamp.fromDate(in20Minutes))
          .get();

      for (var doc in snapshot.docs) {
        final schedule = Schedule.fromFirestore(doc);
        final eventTime = schedule.eventDate;
        final timeDifference = eventTime.difference(now).inMinutes;
        
        final notificationId = '${schedule.id}_${timeDifference}min';
        
        if (_scheduledNotificationIds.contains(notificationId)) continue;
        
        if (timeDifference <= 5 && timeDifference > 0) {
          _sendUrgentNotification(schedule, timeDifference);
          _scheduledNotificationIds.add(notificationId);
        } else if (timeDifference <= 15 && timeDifference > 5) {
          _sendReminderNotification(schedule, timeDifference);
          _scheduledNotificationIds.add(notificationId);
        }
      }
      
    } catch (error) {
      print('Notifications: Check failed - $error');
    }
  }

  /// Send urgent notification
  void _sendUrgentNotification(Schedule schedule, int minutes) {
    sendImmediateNotification(
      title: 'Class Starting Soon!',
      body: '${schedule.title} starts in $minutes minute${minutes == 1 ? '' : 's'} at ${schedule.locationName}',
      tag: 'urgent_${schedule.id}',
      requireInteraction: true,
    );
  }

  /// Send reminder notification
  void _sendReminderNotification(Schedule schedule, int minutes) {
    sendImmediateNotification(
      title: 'Upcoming Event',
      body: '${schedule.title} starts in $minutes minutes at ${schedule}',
      tag: 'reminder_${schedule.id}',
      requireInteraction: false,
    );
  }

  /// Send welcome notification
  void _sendWelcomeNotification() {
    sendImmediateNotification(
      title: 'NUS SmartNavi Notification is Ready!',
      body: 'Notifications enabled! You will receive schedule reminders.',
      tag: 'welcome_notification',
    );
  }

  /// Send immediate notification using modern API
  void sendImmediateNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    bool requireInteraction = false,
  }) {
    if (!_notificationPermissionGranted || !kIsWeb) {
      print('Notifications: Not available on this platform');
      return;
    }

    try {
      final notificationId = _jsCreateNotification(
        title,
        body,
        icon ?? '/icons/Icon-192.png',
        tag ?? 'smartnavi_${DateTime.now().millisecondsSinceEpoch}',
        requireInteraction,
      );

      print('Notifications: Successfully sent - $title (ID: $notificationId)');

      // Auto-close notification after 8 seconds if not requireInteraction
      if (!requireInteraction) {
        Timer(Duration(seconds: 8), () {
          try {
            _jsCloseNotification(notificationId);
          } catch (e) {
            print('Auto-close notification failed: $e');
          }
        });
      }
      
    } catch (error) {
      print('Notifications: Send failed - $error');
    }
  }

  /// Send test notification
  void sendTestNotification() {
    sendImmediateNotification(
      title: 'Test Notification',
      body: 'SmartNavi notification system is working! Time: ${DateTime.now().toString().substring(11, 16)}',
      tag: 'test_notification',
    );
  }

  /// Get notification status
  Map<String, dynamic> getNotificationStatus() {
    return {
      'platform': kIsWeb ? 'web' : 'mobile',
      'isWeb': kIsWeb,
      'supported': kIsWeb ? _isNotificationSupported() : false,
      'permission': kIsWeb ? 'checking...' : 'not_available',
      'enabled': _notificationPermissionGranted,
      'scheduler_active': _notificationTimer?.isActive ?? false,
      'scheduled_count': _scheduledNotificationIds.length,
      'api_version': 'modern_web_api',
    };
  }

  /// Stop notification scheduler
  void stopNotificationScheduler() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _scheduledNotificationIds.clear();
    print('Notifications: Scheduler stopped');
  }

  /// Dispose resources
  void dispose() {
    stopNotificationScheduler();
  }

  // JS interop methods
  /// Check if Notification API exists
  bool _jsHasNotification() {
    return _hasNotificationAPI();
  }

  /// Get notification permission
  String _jsGetNotificationPermission() {
    return _getNotificationPermission();
  }

  /// Request notification permission
  Future<String> _jsRequestNotificationPermission() async {
    final completer = Completer<String>();
    
    _requestNotificationPermissionAsync((String result) {
      completer.complete(result);
    }.toJS);
    
    return completer.future;
  }

  /// Create notification with modern API
  String _jsCreateNotification(String title, String body, String icon, String tag, bool requireInteraction) {
    final notificationId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    
    _createNotification(
      title,
      body,
      icon,
      tag,
      requireInteraction,
      notificationId,
      _onNotificationClick.toJS,
      _onNotificationClose.toJS,
    );
    
    return notificationId;
  }

  /// Close notification
  void _jsCloseNotification(String notificationId) {
    _closeNotification(notificationId);
  }

  /// Handle notification click
  void _onNotificationClick(String notificationId, String title) {
    print('Notification clicked: $title');
    
    try {
      web.window.focus();
      
      // Dispatch a custom event with notification details
      final event = web.CustomEvent('notificationClicked', web.CustomEventInit(
        detail: {
          'id': notificationId,
          'title': title,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }.jsify(),
      ));
      
      web.document.dispatchEvent(event);
      
      // Close the notification
      _jsCloseNotification(notificationId);
      
    } catch (e) {
      print('Error handling notification click: $e');
    }
  }

  /// Handle notification close
  void _onNotificationClose(String notificationId) {
    print('Notification closed: $notificationId');
  }
}

// External JS functions
@JS('window.Notification')
external JSObject? get _notification;

@JS()
external bool _hasNotificationAPI();

@JS()
external String _getNotificationPermission();

@JS()
external void _requestNotificationPermissionAsync(JSFunction callback);

@JS()
external void _createNotification(
  String title,
  String body,
  String icon,
  String tag,
  bool requireInteraction,
  String id,
  JSFunction onClickCallback,
  JSFunction onCloseCallback,
);

@JS()
external void _closeNotification(String id);
