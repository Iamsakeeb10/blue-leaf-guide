import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification ID for goal reminders
  static const int _goalReminderNotificationId = 1;

  // SharedPreferences keys
  static const String _keyGoalReminderEnabled = 'goal_reminder_enabled';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Get device's local timezone
    final String timeZoneName = await _getLocalTimeZone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();
  }

  /// Get the device's local timezone name
  Future<String> _getLocalTimeZone() async {
    // Default to UTC if unable to determine
    try {
      final now = DateTime.now();
      final localOffset = now.timeZoneOffset;

      // Common timezone mappings based on offset
      final offsetHours = localOffset.inHours;

      // This is a simplified approach. For production, consider using
      // flutter_native_timezone package for accurate timezone detection
      final timezoneMap = {
        -5: 'America/New_York',
        -6: 'America/Chicago',
        -7: 'America/Denver',
        -8: 'America/Los_Angeles',
        0: 'Europe/London',
        1: 'Europe/Paris',
        6: 'Asia/Dhaka',
        5: 'Asia/Karachi',
        8: 'Asia/Shanghai',
        9: 'Asia/Tokyo',
      };

      return timezoneMap[offsetHours] ?? 'UTC';
    } catch (e) {
      return 'UTC';
    }
  }

  /// Request notification permissions (primarily for iOS)
  Future<void> _requestPermissions() async {
    // ignore: unused_local_variable
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to goals screen, etc.
    print('Notification tapped: ${response.payload}');
  }

  /// Schedule daily goal reminder notification
  Future<void> scheduleGoalReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelGoalReminder(); // Cancel any existing notification

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'goal_reminders',
          'Goal Reminders',
          channelDescription: 'Daily reminders to track your monthly goals',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _goalReminderNotificationId,
      'Track Your Goals 🎯',
      'Don\'t forget to update your monthly goal progress today!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    print(
      '✅ Goal reminder scheduled for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
    );
  }

  /// Calculate the next instance of the specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel goal reminder notification
  Future<void> cancelGoalReminder() async {
    await _notifications.cancel(_goalReminderNotificationId);
    print('❌ Goal reminder cancelled');
  }

  /// Save reminder settings to SharedPreferences
  Future<void> saveReminderSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGoalReminderEnabled, enabled);
    await prefs.setInt(_keyReminderHour, hour);
    await prefs.setInt(_keyReminderMinute, minute);
  }

  /// Load reminder settings from SharedPreferences
  Future<Map<String, dynamic>> loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_keyGoalReminderEnabled) ?? false,
      'hour': prefs.getInt(_keyReminderHour) ?? 10,
      'minute': prefs.getInt(_keyReminderMinute) ?? 45,
    };
  }

  /// Save reminder settings to Firestore
  Future<void> saveReminderToFirestore({
    required String uid,
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'reminderEnabled': enabled,
        'reminderHour': hour,
        'reminderMinute': minute,
        'reminderUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Reminder settings saved to Firestore');
    } catch (e) {
      print('❌ Error saving to Firestore: $e');
    }
  }

  /// Load reminder settings from Firestore
  Future<Map<String, dynamic>?> loadReminderFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'enabled': data['reminderEnabled'] ?? false,
          'hour': data['reminderHour'] ?? 10,
          'minute': data['reminderMinute'] ?? 45,
        };
      }
    } catch (e) {
      print('❌ Error loading from Firestore: $e');
    }
    return null;
  }

  /// Sync reminder settings (Firestore -> Local -> Schedule)
  Future<void> syncReminderSettings(String uid) async {
    try {
      // Load from Firestore
      final firestoreSettings = await loadReminderFromFirestore(uid);

      if (firestoreSettings != null) {
        final enabled = firestoreSettings['enabled'] as bool;
        final hour = firestoreSettings['hour'] as int;
        final minute = firestoreSettings['minute'] as int;

        // Save to local storage
        await saveReminderSettings(
          enabled: enabled,
          hour: hour,
          minute: minute,
        );

        // Schedule notification if enabled
        if (enabled) {
          await scheduleGoalReminder(hour: hour, minute: minute);
        } else {
          await cancelGoalReminder();
        }

        print('✅ Reminder settings synced from Firestore');
      }
    } catch (e) {
      print('❌ Error syncing reminder settings: $e');
    }
  }
}
