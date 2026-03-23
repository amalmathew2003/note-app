import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    // ✅ CRITICAL Timezone sync
    try {
      final currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone.toString()));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
    
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {},
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String sound = 'Standard',
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final String channelId = sound == 'Urgent' ? 'urgent_final_v1' : 'standard_final_v1';
    final String channelName = sound == 'Urgent' ? 'Urgent Alarms' : 'Standard Reminders';
    
    final Importance importance = sound == 'Urgent' ? Importance.max : Importance.high;
    final Priority priority = sound == 'Urgent' ? Priority.high : Priority.defaultPriority;

    final tz.TZDateTime tzTime = tz.TZDateTime.local(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    // ✅ FIXED: Using 100% NAMED parameters as required by your plugin version
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId, 
          channelName,
          importance: importance,
          priority: priority,
          playSound: true,
          fullScreenIntent: sound == 'Urgent',
          audioAttributesUsage: sound == 'Urgent' ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
          enableVibration: true,
          vibrationPattern: sound == 'Urgent' ? Int64List.fromList([0, 1000, 500, 1000]) : null,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Removed interpretation as it was causing 'Undefined' errors in your IDE
    );
  }

  Future<void> showImmediateConfirmation(String time) async {
    await _notificationsPlugin.show(
      id: 999999,
      title: "Reminder Set! ✅",
      body: "I will remind you at $time",
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'confirm_final_v1',
          'Confirmations',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}
