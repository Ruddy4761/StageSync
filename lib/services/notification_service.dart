import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/concert.dart';

/// Service for scheduling local notifications for concerts and tasks.
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize the notification service. Call once from main().
  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  /// Request notification permissions from the user.
  static Future<bool> requestPermissions() async {
    // Request Android 13+ notification permission
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Schedule notifications for 24 hours and 1 hour before a concert.
  /// Cancels any existing notifications for the same concert first.
  static Future<void> scheduleForConcert(Concert concert) async {
    if (!_initialized) await initialize();

    // Cancel existing notifications for this concert (using hash of id)
    final base = concert.id.hashCode.abs() % 100000;
    await _plugin.cancel(base);
    await _plugin.cancel(base + 1);

    final now = DateTime.now();
    final eventTime = concert.dateTime;

    // 24 hour reminder
    final remind24h = eventTime.subtract(const Duration(hours: 24));
    if (remind24h.isAfter(now)) {
      await _scheduleNotification(
        id: base,
        title: '🎵 Concert Tomorrow!',
        body: '${concert.name} at ${concert.venue} is in 24 hours. Get ready!',
        scheduledTime: remind24h,
      );
    }

    // 1 hour reminder
    final remind1h = eventTime.subtract(const Duration(hours: 1));
    if (remind1h.isAfter(now)) {
      await _scheduleNotification(
        id: base + 1,
        title: '⏰ Concert Starting Soon!',
        body:
            '${concert.name} starts in 1 hour at ${concert.venue}. Time to wrap up!',
        scheduledTime: remind1h,
      );
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'stagesync_channel',
            'StageSync Reminders',
            channelDescription: 'Concert and task reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (_) {
      // Silently fail — notifications are optional functionality
    }
  }

  /// Cancel all notifications for a concert.
  static Future<void> cancelForConcert(String concertId) async {
    final base = concertId.hashCode.abs() % 100000;
    await _plugin.cancel(base);
    await _plugin.cancel(base + 1);
  }

  /// Show an immediate notification (e.g., new team member joined).
  static Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();
    try {
      await _plugin.show(
        99999,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'stagesync_channel',
            'StageSync Reminders',
            channelDescription: 'Concert and task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
      );
    } catch (_) {}
  }
}
