import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class FirestoreService {
  
  // Schedule related collections
  final CollectionReference _schedulesCollection = 
      FirebaseFirestore.instance.collection('schedules');

  // Get current user ID
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // navigation related collections
  final CollectionReference _venuesCollection = 
      FirebaseFirestore.instance.collection('Venues');
      
  final CollectionReference _routesCollection = 
      FirebaseFirestore.instance.collection('Routes');
  
  // Schedule methods
  
  // Get a stream of current user's schedules
Stream<List<Schedule>> getSchedules() {
  final userId = _currentUserId;
  
  if (userId == null) {
    print('No current user - returning empty stream');
    return Stream.value([]);
  }
  
  return _schedulesCollection
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        
        if (snapshot.docs.isEmpty) {
          print('No documents found for user: $userId');
          return <Schedule>[];
        }
        
        final schedules = <Schedule>[];
        for (int i = 0; i < snapshot.docs.length; i++) {
          final doc = snapshot.docs[i];
          try {
            final schedule = Schedule.fromFirestore(doc);
            schedules.add(schedule);
            
          } catch (e, stackTrace) {
            print('Error parsing document ${doc.id}: $e');
            print('Stack trace: $stackTrace');
          }
        }

        schedules.sort((a, b) => a.eventDate.compareTo(b.eventDate)); // Don't use orderby(), use Dart's sort

        return schedules;
      });
}

  // Add a new schedule
  // In lib/services/firestore_service.dart

// CHANGE THIS METHOD
Future<void> addSchedule(Schedule schedule) async {
  final userId = _currentUserId;
  if (userId == null) throw Exception('User not authenticated');

  try {
    // 1. Create the data map from the incoming schedule
    final scheduleData = schedule.toFirestore();
    // 2. Ensure the correct userId is set
    scheduleData['userId'] = userId; 

    // 3. Add to Firestore and GET THE REFERENCE BACK
    final DocumentReference docRef = await _schedulesCollection.add(scheduleData);

    // 4. Create a FINAL schedule object that includes the REAL ID
    final finalSchedule = Schedule(
      id: docRef.id, // <-- Use the NEWLY generated ID
      title: schedule.title,
      eventDate: schedule.eventDate,
      endDate: schedule.endDate,
      locationName: schedule.locationName,
      userId: userId,
    );

    // 5. Call the check with the complete, correct schedule object
    // Force check immediate notification regardless of cached permission state
    print('=== FORCE CHECKING IMMEDIATE NOTIFICATION ===');
    print('Permission granted (cached): $_notificationPermissionGranted');
    print('Notifications enabled (cached): $_notificationEnabled');
    
    // Check current real-time permission status
    final currentPermission = await _getCurrentPermission();
    final currentEnabled = await getNotificationEnabled();
    
    print('Permission granted (real-time): ${currentPermission == 'granted'}');
    print('Notifications enabled (real-time): $currentEnabled');
    
    // Update cached values with real-time check
    _notificationPermissionGranted = (currentPermission == 'granted');
    _notificationEnabled = currentEnabled;
    
    if (_notificationPermissionGranted && _notificationEnabled) {
      await _checkSingleScheduleForImmediateNotification(finalSchedule);
    } else {
      print('Skipping immediate notification: permission=$_notificationPermissionGranted, enabled=$_notificationEnabled');
    }
  } catch (e) {
    throw Exception('Failed to add schedule: $e');
  }
}

  // Update a schedule 
  Future<void> updateSchedule(Schedule schedule) async {
  final userId = _currentUserId;
  if (userId == null) throw Exception('User not authenticated');

  try {
    // ... (keep all your user and document validation checks)
    final doc = await _schedulesCollection.doc(schedule.id).get();
    if (!doc.exists) throw Exception('Schedule not found');
    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != userId) {
      throw Exception('Unauthorized: Cannot update another user\'s schedule');
    }

    // Rebuild the schedule object to ensure it has the correct data
    final scheduleWithUserId = Schedule(
      id: schedule.id,
      title: schedule.title,
      eventDate: schedule.eventDate,
      endDate: schedule.endDate,
      locationName: schedule.locationName,
      userId: userId,
    );
    
    // Update using the guaranteed-correct object
    await _schedulesCollection.doc(schedule.id).update(scheduleWithUserId.toFirestore());

    // Check for notifications using the same guaranteed-correct object
    // Force real-time permission check for update notification too
    final currentPermission = await _getCurrentPermission();
    final currentEnabled = await getNotificationEnabled();
    _notificationPermissionGranted = (currentPermission == 'granted');
    _notificationEnabled = currentEnabled;
    
    if (_notificationPermissionGranted && _notificationEnabled) {
      await _checkSingleScheduleForImmediateNotification(scheduleWithUserId);
    }

  } catch (e) {
    throw Exception('Failed to update schedule: $e');
  }
}

  // Delete a schedule
  Future<void> deleteSchedule(String id) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      // check if the schedule belongs to the current user
      final doc = await _schedulesCollection.doc(id).get();
      if (!doc.exists) {
        throw Exception('Schedule not found');
      }
      
      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        throw Exception('Unauthorized: Cannot delete another user\'s schedule');
      }
      
      await _schedulesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  Future<Schedule?> getScheduleById(String scheduleId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      DocumentSnapshot doc = await _schedulesCollection.doc(scheduleId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // check if the schedule belongs to the current user
        if (data['userId'] != userId) {
          return null; // dont return schedules that don't belong to the current user
        }
        return Schedule.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get schedule: $e');
    }
  }

  // Get upcoming schedules for current user
  Stream<List<Schedule>> getUpcomingSchedules() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _schedulesCollection
        .where('userId', isEqualTo: userId) // only get current user's schedules
        .where('eventDate', isGreaterThan: Timestamp.now())
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }

  // Get today's schedules for current user
  Stream<List<Schedule>> getTodaySchedules() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }
    
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return _schedulesCollection
        .where('userId', isEqualTo: userId) 
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('eventDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Schedule.fromFirestore(doc))
            .toList());
  }

  // Navigation Methods
  
  Future<List<String>> getStationNames() async {
    try {
      final snapshot = await _venuesCollection.get();
      final stationNames = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['name'] as String)
          .toList();
      return stationNames;
    } catch (e) {
      print("Error fetching station names: $e");
      return [];
    }
  }

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

  // Notification properties
  Timer? _notificationTimer;
  bool _notificationPermissionGranted = false;
  bool _notificationEnabled = true;
  final Set<String> _scheduledNotificationIds = <String>{};

  static const List<int> _reminderThresholds = [
    1200, // 20 minutes
    600,  // 10 minutes
    60,   // 1 minute
  ];
  
  // SharedPreferences key for notification settings
  static const String _notificationEnabledKey = 'notification_enabled';

  
  /// Get notification enabled status from local storage
  Future<bool> getNotificationEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationEnabled = prefs.getBool(_notificationEnabledKey) ?? true;
      return _notificationEnabled;
    } catch (e) {
      print('Error getting notification enabled status: $e');
      return true; // Default to enabled
    }
  }
  
  /// Set notification enabled status and save to local storage
  Future<void> setNotificationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationEnabledKey, enabled);
      _notificationEnabled = enabled;
      
      if (enabled && _notificationPermissionGranted) {
        // Start scheduler if notifications are enabled
        _startNotificationScheduler();
        print('Notifications: Enabled and scheduler started');
      } else {
        // Stop scheduler if notifications are disabled
        stopNotificationScheduler();
        print('Notifications: Disabled and scheduler stopped');
      }
    } catch (e) {
      print('Error setting notification enabled status: $e');
    }
  }
  
  /// Get current browser notification permission status
  Future<String> getNotificationPermission() async {
    if (!kIsWeb) return 'not_supported';
    return await _getCurrentPermission();
  }
  
  /// Request notification permission from browser
  Future<String> requestNotificationPermission() async {
    if (!kIsWeb) return 'not_supported';
    
    try {
      String permission = await _requestPermission();
      _notificationPermissionGranted = (permission == 'granted');
      
      if (_notificationPermissionGranted && _notificationEnabled) {
        _startNotificationScheduler();
        _sendWelcomeNotification();
      }
      
      return permission;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return 'error';
    }
  }
  
  /// Check if notifications are fully enabled (permission + app setting)
  bool isNotificationFullyEnabled() {
    return _notificationPermissionGranted && _notificationEnabled;
  }

  // Notification methods

  /// Initialize notifications using modern Web API
  Future<bool> initializeNotifications() async {
    if (!kIsWeb) {
      print('Notifications: Not available on mobile platform');
      return false;
    }

    try {
      // Load notification enabled setting from storage
      await getNotificationEnabled();
      
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
          // Only start scheduler if app-level notifications are also enabled
          if (_notificationEnabled) {
            _startNotificationScheduler();
          }
          print('Notifications: Permission already granted, enabled: $_notificationEnabled');
          return true;
          
        case 'denied':
          print('Notifications: Permission previously denied');
          return false;
          
        case 'default':
        default:
          // Don't automatically request permission - let user control this
          print('Notifications: Permission not requested yet');
          return false;
      }
      
    } catch (error) {
      print('Notifications: Initialization failed - $error');
      return false;
    }
  }

  // Check if a schedule is within 20 minutes and send immediate notification
  Future<void> _checkSingleScheduleForImmediateNotification(Schedule schedule) async {
    try {
      final now = DateTime.now();
      final timeDifferenceInSeconds = schedule.eventDate.difference(now).inSeconds;
      final minutes = (timeDifferenceInSeconds / 60).ceil();
      
      print('=== IMMEDIATE NOTIFICATION CHECK ===');
      print('Event: ${schedule.title}');
      print('Event time: ${schedule.eventDate.toString().substring(11, 19)}');
      print('Current time: ${now.toString().substring(11, 19)}');
      print('Time diff: ${timeDifferenceInSeconds}s (${minutes} minutes)');
      print('Notification permission: $_notificationPermissionGranted');
      print('Notification enabled: $_notificationEnabled');
      
      // Only notify for future events within 20 minutes
      if (timeDifferenceInSeconds > 0 && timeDifferenceInSeconds <= 1200) {
        final notificationId = 'creation_${schedule.id}';
        
        print('Event is within 20 minutes, checking if notification already sent...');
        print('Notification ID: $notificationId');
        print('Already sent: ${_scheduledNotificationIds.contains(notificationId)}');
        
        if (!_scheduledNotificationIds.contains(notificationId)) {
          String title;
          bool requireInteraction;
          
          if (minutes <= 5) {
            title = 'New Event Starting Soon!';
            requireInteraction = true;
          } else {
            title = 'New Event Created';
            requireInteraction = false;
          }
          
          print('Sending immediate notification: $title');
          
          sendImmediateNotification(
            title: title,
            body: '${schedule.title} starts in $minutes minute${minutes == 1 ? '' : 's'} at ${schedule.locationName}',
            tag: notificationId,
            requireInteraction: requireInteraction,
          );
          _scheduledNotificationIds.add(notificationId);
          
          print('✓ Sent creation notification for event in $minutes minutes');
        } else {
          print('× Notification already sent for this event');
        }
      } else {
        if (timeDifferenceInSeconds <= 0) {
          print('× Event is in the past, skipping notification');
        } else {
          print('× Event is more than 20 minutes away (${(timeDifferenceInSeconds/60).ceil()} minutes), skipping notification');
        }
      }
      print('=== END IMMEDIATE NOTIFICATION CHECK ===');
    } catch (e) {
      print('Error in immediate notification check: $e');
    }
  }

  Future<void> _processScheduleForSmartNotification(Schedule schedule, DateTime now) async {
    final timeDifferenceInSeconds = schedule.eventDate.difference(now).inSeconds;
    
    // Only process future events
    if (timeDifferenceInSeconds <= 0) return;
    
    print('Processing schedule for notification: ${schedule.title}, time diff: ${timeDifferenceInSeconds}s');
    
    // Check each critical time point
    for (int thresholdSeconds in _reminderThresholds) {
      // Calculate difference from threshold (increased tolerance to 30 seconds)
      final diffFromThreshold = (timeDifferenceInSeconds - thresholdSeconds).abs();
      
      print('Checking threshold ${thresholdSeconds}s: diff=${diffFromThreshold}s');
      
      // If current time difference is close to a threshold (within 30-second tolerance)
      if (diffFromThreshold <= 30) {
        final notificationId = '${schedule.id}_${thresholdSeconds}s';
        
        // Check if notification already sent for this threshold
        if (!_scheduledNotificationIds.contains(notificationId)) {
          _sendSmartNotification(schedule, timeDifferenceInSeconds, thresholdSeconds);
          _scheduledNotificationIds.add(notificationId);
          
          print('Sent scheduled notification for ${thresholdSeconds}s threshold');
          break; // Send only one notification at a time to avoid spam
        } else {
          print('Notification already sent for threshold ${thresholdSeconds}s');
        }
      }
    }
  }

  // Send notification based on time thresholds 20 minutes, 10 minutes, and 1 minute
  void _sendSmartNotification(Schedule schedule, int actualSeconds, int thresholdSeconds) {
    final minutes = (actualSeconds / 60).round();
    String title;
    String body;
    bool requireInteraction;
    
    if (thresholdSeconds >= 1200) {
      // 20-minute reminder
      title = 'Upcoming Event';
      body = '${schedule.title} starts in about $minutes minutes at ${schedule.locationName}';
      requireInteraction = false;
    } else if (thresholdSeconds >= 600) {
      // 10-minute reminder
      title = 'Event Reminder';
      body = '${schedule.title} starts in $minutes minutes at ${schedule.locationName}. Time to prepare!';
      requireInteraction = false;
    } else {
      // 1-minute reminder (urgent)
      title = 'Event Starting Soon!';
      body = '${schedule.title} starts in $minutes minute${minutes == 1 ? '' : 's'} at ${schedule.locationName}';
      requireInteraction = true;
    }
    
    sendImmediateNotification(
      title: title,
      body: body,
      tag: 'smart_${schedule.id}_${thresholdSeconds}s',
      requireInteraction: requireInteraction,
    );
  }

  void _checkAndSendUpcomingNotifications() async {
  if (!_notificationPermissionGranted || !_notificationEnabled || !kIsWeb) return;

  final userId = _currentUserId;
  if (userId == null) return;

  try {
    final now = DateTime.now();
    final in25Minutes = now.add(Duration(seconds: 1500)); // 25 minutes with buffer
    
    print('Checking notifications: current time=${now.toString().substring(11, 19)}');
    
    final snapshot = await _schedulesCollection
        .where('userId', isEqualTo: userId)
        .where('eventDate', isGreaterThan: Timestamp.fromDate(now))
        .where('eventDate', isLessThan: Timestamp.fromDate(in25Minutes))
        .get();

    print('Found ${snapshot.docs.length} upcoming events within 25 minutes');

    for (var doc in snapshot.docs) {
      final schedule = Schedule.fromFirestore(doc);
      await _processScheduleForSmartNotification(schedule, now); 
    }
    
  } catch (error) {
    print('Notifications: Check failed - $error');
  }
}
  
  /// Check app setting before sending notification
  void sendImmediateNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    bool requireInteraction = false,
  }) {
    // Check both permission and app setting
    if (!_notificationPermissionGranted || !_notificationEnabled || !kIsWeb) {
      print('Notifications: Not enabled or not available');
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

  /// Get complete notification status
  Map<String, dynamic> getNotificationStatus() {
    return {
      'platform': kIsWeb ? 'web' : 'mobile',
      'isWeb': kIsWeb,
      'supported': kIsWeb ? _isNotificationSupported() : false,
      'browser_permission': _notificationPermissionGranted ? 'granted' : 'not_granted',
      'app_enabled': _notificationEnabled,  // New: App-level setting status
      'fully_enabled': isNotificationFullyEnabled(),  // New: Complete enabled status
      'scheduler_active': _notificationTimer?.isActive ?? false,
      'scheduled_count': _scheduledNotificationIds.length,
      'api_version': 'modern_web_api',
    };
  }

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

  bool _checkNotificationAPI() {
    try {
      return _jsHasNotification();
    } catch (e) {
      return false;
    }
  }

  Future<String> _getCurrentPermission() async {
    if (!kIsWeb) return 'denied';
    
    try {
      return _jsGetNotificationPermission();
    } catch (e) {
      print('Error getting notification permission: $e');
      return 'denied';
    }
  }

  Future<String> _requestPermission() async {
    if (!kIsWeb) return 'denied';
    
    try {
      return await _jsRequestNotificationPermission();
    } catch (e) {
      print('Error requesting notification permission: $e');
      return 'denied';
    }
  }

  void _startNotificationScheduler() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _checkAndSendUpcomingNotifications();
    });
    print('Notifications: Scheduler started (checking every 10 seconds)');
  }

  void _sendUrgentNotification(Schedule schedule, int minutes) {
    sendImmediateNotification(
      title: 'Event Starting Soon!',
      body: '${schedule.title} starts in $minutes minute${minutes == 1 ? '' : 's'} at ${schedule.locationName}',
      tag: 'urgent_${schedule.id}',
      requireInteraction: true,
    );
  }

  void _sendReminderNotification(Schedule schedule, int minutes) {
    sendImmediateNotification(
      title: 'Upcoming Event',
      body: '${schedule.title} starts in $minutes minutes at ${schedule.locationName}',
      tag: 'reminder_${schedule.id}',
      requireInteraction: false,
    );
  }

  void _sendWelcomeNotification() {
    sendImmediateNotification(
      title: 'NUS SmartNavi Notification is Ready!',
      body: 'Notifications enabled! You will receive schedule reminders.',
      tag: 'welcome_notification',
    );
  }

  void sendTestNotification() {
    print('=== SENDING TEST NOTIFICATION ===');
    print('Permission granted: $_notificationPermissionGranted');
    print('Notification enabled: $_notificationEnabled');
    print('Platform: ${kIsWeb ? 'web' : 'mobile'}');
    
    sendImmediateNotification(
      title: 'Test Notification',
      body: 'SmartNavi notification system is working! Time: ${DateTime.now().toString().substring(11, 16)}',
      tag: 'test_notification',
      requireInteraction: false,
    );
    print('=== TEST NOTIFICATION SENT ===');
  }

  // New method to test 20-minute notification specifically
  void testTwentyMinuteNotification() {
    print('=== TESTING 20-MINUTE NOTIFICATION ===');
    
    // Create a test schedule 15 minutes in the future
    final testTime = DateTime.now().add(Duration(minutes: 15));
    final testSchedule = Schedule(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Event (15 min)',
      eventDate: testTime,
      endDate: testTime.add(Duration(hours: 1)),
      locationName: 'Test Location',
      userId: _currentUserId ?? 'test_user',
    );
    
    _checkSingleScheduleForImmediateNotification(testSchedule);
    print('=== 20-MINUTE TEST COMPLETED ===');
  }

  // Debug method to check current permission state
  void debugNotificationState() {
    print('=== NOTIFICATION DEBUG STATE ===');
    print('kIsWeb: $kIsWeb');
    print('_notificationPermissionGranted: $_notificationPermissionGranted');
    print('_notificationEnabled: $_notificationEnabled');
    print('_currentUserId: $_currentUserId');
    print('isNotificationFullyEnabled(): ${isNotificationFullyEnabled()}');
    print('_scheduledNotificationIds.length: ${_scheduledNotificationIds.length}');
    
    // Check current browser permission
    _getCurrentPermission().then((permission) {
      print('Current browser permission: $permission');
    });
    
    print('=== END DEBUG STATE ===');
  }

  void stopNotificationScheduler() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _scheduledNotificationIds.clear();
    print('Notifications: Scheduler stopped');
  }

  void dispose() {
    stopNotificationScheduler();
  }

  // JS Interop Methods
  
  bool _jsHasNotification() {
    return _hasNotificationAPI();
  }

  String _jsGetNotificationPermission() {
    return _getNotificationPermission();
  }

  Future<String> _jsRequestNotificationPermission() async {
    final completer = Completer<String>();
    
    _requestNotificationPermissionAsync((String result) {
      completer.complete(result);
    }.toJS);
    
    return completer.future;
  }

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

  void _jsCloseNotification(String notificationId) {
    _closeNotification(notificationId);
  }

  void _onNotificationClick(String notificationId, String title) {
    print('Notification clicked: $title');
    
    try {
      web.window.focus();
      
      final event = web.CustomEvent('notificationClicked', web.CustomEventInit(
        detail: {
          'id': notificationId,
          'title': title,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }.jsify(),
      ));
      
      web.document.dispatchEvent(event);
      _jsCloseNotification(notificationId);
      
    } catch (e) {
      print('Error handling notification click: $e');
    }
  }

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
