// packages/remind_me/lib/src/remind_me.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart' show FlutterTimezone;
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:remind_me/src/notification_permission_status.dart';
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

  /// Reads the current OS notification permission state without
  /// prompting the user.
  ///
  /// Use this on screens that need to display permission state or pick
  /// between "request" and "open settings" actions. Cheap to call.
  ///
  /// Returns [NotificationPermissionStatus.notDetermined] when the user
  /// has not yet been prompted, [NotificationPermissionStatus.granted]
  /// after consent, [NotificationPermissionStatus.denied] when the user
  /// declined but can still be re-prompted, and
  /// [NotificationPermissionStatus.permanentlyDenied] when the OS will
  /// no longer surface the prompt — the only path forward from this
  /// state is [openSettings].
  Future<NotificationPermissionStatus> currentStatus() async {
    final raw = await ph.Permission.notification.status;
    return switch (raw) {
      ph.PermissionStatus.granted ||
      ph.PermissionStatus.provisional => NotificationPermissionStatus.granted,
      ph.PermissionStatus.denied => NotificationPermissionStatus.denied,
      ph.PermissionStatus.permanentlyDenied =>
        NotificationPermissionStatus.permanentlyDenied,
      ph.PermissionStatus.restricted =>
        NotificationPermissionStatus.restricted,
      // `limited` is iOS-only and used by other permissions (e.g.
      // photos); for notifications it does not occur in practice but is
      // mapped to `granted` to be safe — the user has elected to allow
      // some notifications.
      ph.PermissionStatus.limited => NotificationPermissionStatus.granted,
    };
  }

  /// Opens the OS settings screen for this app, where the user can
  /// toggle notification permission directly.
  ///
  /// Returns `true` if the settings screen was successfully launched.
  /// Use this from UI shown when [currentStatus] returns
  /// [NotificationPermissionStatus.permanentlyDenied] (the user can
  /// no longer be prompted in-app), or as an always-available secondary
  /// action so users can revoke previously-granted permission without
  /// hunting through OS settings manually.
  Future<bool> openSettings() => ph.openAppSettings();

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
