// ignore_for_file: public_member_api_docs
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart' show FlutterTimezone;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class RemindMe {
  RemindMe._();
  static final RemindMe instance = RemindMe._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'reminders';
  static const _channelName = 'Reminders';

  Future<void> init() async {
    tzdata.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<bool> requestPermissions() async {
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosOk = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidOk = await androidImpl?.requestNotificationsPermission();

    return (iosOk ?? true) && (androidOk ?? true);
  }

  Future<bool> requestExactAlarmsPermission() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl == null) return true;

    final granted = await androidImpl.canScheduleExactNotifications() ?? false;
    if (granted) return true;

    return await androidImpl.requestExactAlarmsPermission() ?? false;
  }

  Future<bool> canScheduleExactAlarms() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl == null) return true;
    return await androidImpl.canScheduleExactNotifications() ?? false;
  }

  Future<int> scheduleInMinutes({
    required String title,
    required String body,
    Duration duration = const Duration(minutes: 5),
  }) async {
    assert(duration.inHours < Duration.hoursPerDay, 'Duration must be < 24hrs');
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    final when = tz.TZDateTime.now(tz.local).add(duration);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'User-set reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    return id;
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
}
