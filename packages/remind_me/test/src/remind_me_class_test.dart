// packages/remind_me/test/src/remind_me_class_test.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remind_me/src/notification_permission_status.dart';
import 'package:remind_me/src/remind_me_class.dart';
import 'package:timezone/timezone.dart' as tz;

/// The method channel backing `flutter_local_notifications` on Android
/// and iOS.
const MethodChannel _notificationsChannel = MethodChannel(
  'dexterous.com/flutter/local_notifications',
);

/// The method channel backing `flutter_timezone`.
const MethodChannel _timezoneChannel = MethodChannel('flutter_timezone');

/// The method channel backing `permission_handler`.
const MethodChannel _permissionsChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

/// The timezone identifier the mocked platform reports.
const String _kTimezoneId = 'Europe/Berlin';

/// `permission_handler`'s wire value for `Permission.notification`.
const int _kNotificationPermissionValue = 17;

/// `permission_handler`'s `PermissionStatus` wire indices.
const int _kDenied = 0;
const int _kGranted = 1;
const int _kRestricted = 2;
const int _kLimited = 3;
const int _kPermanentlyDenied = 4;
const int _kProvisional = 5;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final notificationCalls = <MethodCall>[];
  final timezoneCalls = <MethodCall>[];
  final permissionCalls = <MethodCall>[];

  late Map<String, Object?> notificationResults;
  late Object? permissionStatusResult;
  late bool openAppSettingsResult;

  TestDefaultBinaryMessenger messenger() =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Points `flutter_local_notifications` at its iOS implementation, as
  /// the plugin registrant would on an iPhone.
  void useIosPlatform() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
  }

  MethodCall callNamed(List<MethodCall> log, String method) =>
      log.singleWhere((call) => call.method == method);

  bool wasCalled(List<MethodCall> log, String method) =>
      log.any((call) => call.method == method);

  setUp(() {
    notificationCalls.clear();
    timezoneCalls.clear();
    permissionCalls.clear();

    notificationResults = <String, Object?>{
      'initialize': true,
      'requestNotificationsPermission': true,
      'requestPermissions': true,
      'canScheduleExactNotifications': true,
      'requestExactAlarmsPermission': true,
      'zonedSchedule': null,
      'cancel': null,
    };
    permissionStatusResult = _kGranted;
    openAppSettingsResult = true;

    // Tests run as Android by default; the registrant never runs under
    // `flutter test`, so register the implementation explicitly.
    AndroidFlutterLocalNotificationsPlugin.registerWith();

    messenger().setMockMethodCallHandler(_notificationsChannel, (call) async {
      notificationCalls.add(call);
      return notificationResults[call.method];
    });
    messenger().setMockMethodCallHandler(_timezoneChannel, (call) async {
      timezoneCalls.add(call);
      return _kTimezoneId;
    });
    messenger().setMockMethodCallHandler(_permissionsChannel, (call) async {
      permissionCalls.add(call);
      return switch (call.method) {
        'checkPermissionStatus' => permissionStatusResult,
        'openAppSettings' => openAppSettingsResult,
        _ => null,
      };
    });
  });

  tearDown(() {
    messenger().setMockMethodCallHandler(_notificationsChannel, null);
    messenger().setMockMethodCallHandler(_timezoneChannel, null);
    messenger().setMockMethodCallHandler(_permissionsChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('instance', () {
    test('is a shared singleton', () {
      expect(RemindMe.instance, same(RemindMe.instance));
    });
  });

  group('init', () {
    test('resolves and applies the device timezone as local', () async {
      await RemindMe.instance.init();

      expect(callNamed(timezoneCalls, 'getLocalTimezone'), isNotNull);
      expect(tz.local.name, _kTimezoneId);
    });

    test('initializes the plugin silently with the launcher icon', () async {
      await RemindMe.instance.init();

      final call = callNamed(notificationCalls, 'initialize');
      final arguments = Map<Object?, Object?>.from(call.arguments as Map);
      expect(arguments['defaultIcon'], '@mipmap/ic_launcher');
    });
  });

  group('requestPermissions', () {
    test('returns true when Android grants notifications', () async {
      notificationResults['requestNotificationsPermission'] = true;

      final granted = await RemindMe.instance.requestPermissions();

      expect(granted, isTrue);
      expect(
        callNamed(notificationCalls, 'requestNotificationsPermission'),
        isNotNull,
      );
    });

    test('returns false when Android denies notifications', () async {
      notificationResults['requestNotificationsPermission'] = false;

      expect(await RemindMe.instance.requestPermissions(), isFalse);
    });

    test('requests alert, badge, and sound on iOS', () async {
      useIosPlatform();
      notificationResults['requestPermissions'] = true;

      final granted = await RemindMe.instance.requestPermissions();

      expect(granted, isTrue);
      final call = callNamed(notificationCalls, 'requestPermissions');
      final arguments = Map<Object?, Object?>.from(call.arguments as Map);
      expect(arguments['alert'], isTrue);
      expect(arguments['badge'], isTrue);
      expect(arguments['sound'], isTrue);
      expect(
        wasCalled(notificationCalls, 'requestNotificationsPermission'),
        isFalse,
      );
    });

    test('returns false when iOS denies notifications', () async {
      useIosPlatform();
      notificationResults['requestPermissions'] = false;

      expect(await RemindMe.instance.requestPermissions(), isFalse);
    });
  });

  group('requestExactAlarmsPermission', () {
    test('returns true without the settings flow when granted', () async {
      notificationResults['canScheduleExactNotifications'] = true;

      final granted = await RemindMe.instance.requestExactAlarmsPermission();

      expect(granted, isTrue);
      expect(
        wasCalled(notificationCalls, 'requestExactAlarmsPermission'),
        isFalse,
      );
    });

    test('launches the settings flow and reports a grant', () async {
      notificationResults['canScheduleExactNotifications'] = false;
      notificationResults['requestExactAlarmsPermission'] = true;

      expect(await RemindMe.instance.requestExactAlarmsPermission(), isTrue);
      expect(
        callNamed(notificationCalls, 'requestExactAlarmsPermission'),
        isNotNull,
      );
    });

    test('launches the settings flow and reports a denial', () async {
      notificationResults['canScheduleExactNotifications'] = false;
      notificationResults['requestExactAlarmsPermission'] = false;

      expect(await RemindMe.instance.requestExactAlarmsPermission(), isFalse);
    });

    test('treats a null capability answer as not granted', () async {
      notificationResults['canScheduleExactNotifications'] = null;
      notificationResults['requestExactAlarmsPermission'] = false;

      expect(await RemindMe.instance.requestExactAlarmsPermission(), isFalse);
      expect(
        callNamed(notificationCalls, 'requestExactAlarmsPermission'),
        isNotNull,
      );
    });

    test('treats a null flow answer as a denial', () async {
      notificationResults['canScheduleExactNotifications'] = false;
      notificationResults['requestExactAlarmsPermission'] = null;

      expect(await RemindMe.instance.requestExactAlarmsPermission(), isFalse);
    });

    test('returns true on platforms without exact alarms', () async {
      useIosPlatform();

      expect(await RemindMe.instance.requestExactAlarmsPermission(), isTrue);
      expect(notificationCalls, isEmpty);
    });
  });

  group('canScheduleExactAlarms', () {
    test('reports true when the capability is held', () async {
      notificationResults['canScheduleExactNotifications'] = true;

      expect(await RemindMe.instance.canScheduleExactAlarms(), isTrue);
    });

    test('reports false when the capability is missing', () async {
      notificationResults['canScheduleExactNotifications'] = false;

      expect(await RemindMe.instance.canScheduleExactAlarms(), isFalse);
    });

    test('treats a null answer as false', () async {
      notificationResults['canScheduleExactNotifications'] = null;

      expect(await RemindMe.instance.canScheduleExactAlarms(), isFalse);
    });

    test('reports true on platforms without exact alarms', () async {
      useIosPlatform();

      expect(await RemindMe.instance.canScheduleExactAlarms(), isTrue);
      expect(notificationCalls, isEmpty);
    });
  });

  group('currentStatus', () {
    test('queries the notification permission without prompting', () async {
      await RemindMe.instance.currentStatus();

      final call = callNamed(permissionCalls, 'checkPermissionStatus');
      expect(call.arguments, _kNotificationPermissionValue);
    });

    test('maps granted to granted', () async {
      permissionStatusResult = _kGranted;

      expect(
        await RemindMe.instance.currentStatus(),
        NotificationPermissionStatus.granted,
      );
    });

    test('maps provisional to granted', () async {
      permissionStatusResult = _kProvisional;

      expect(
        await RemindMe.instance.currentStatus(),
        NotificationPermissionStatus.granted,
      );
    });

    test('maps denied to denied', () async {
      permissionStatusResult = _kDenied;

      expect(
        await RemindMe.instance.currentStatus(),
        NotificationPermissionStatus.denied,
      );
    });

    test('maps permanentlyDenied to permanentlyDenied', () async {
      permissionStatusResult = _kPermanentlyDenied;

      expect(
        await RemindMe.instance.currentStatus(),
        NotificationPermissionStatus.permanentlyDenied,
      );
    });

    test('maps restricted to restricted', () async {
      permissionStatusResult = _kRestricted;

      expect(
        await RemindMe.instance.currentStatus(),
        NotificationPermissionStatus.restricted,
      );
    });

    test('maps limited to granted', () async {
      permissionStatusResult = _kLimited;

      expect(
        await RemindMe.instance.currentStatus(),
        NotificationPermissionStatus.granted,
      );
    });
  });

  group('openSettings', () {
    test('reports a successful settings launch', () async {
      openAppSettingsResult = true;

      expect(await RemindMe.instance.openSettings(), isTrue);
      expect(callNamed(permissionCalls, 'openAppSettings'), isNotNull);
    });

    test('reports a failed settings launch', () async {
      openAppSettingsResult = false;

      expect(await RemindMe.instance.openSettings(), isFalse);
    });
  });

  group('scheduleInMinutes', () {
    test('schedules on the reminders channel with the sent id', () async {
      await RemindMe.instance.init();

      final id = await RemindMe.instance.scheduleInMinutes(
        title: 'Stand up',
        body: 'Stretch your legs',
      );

      final call = callNamed(notificationCalls, 'zonedSchedule');
      final arguments = Map<Object?, Object?>.from(call.arguments as Map);
      expect(arguments['id'], id);
      expect(arguments['title'], 'Stand up');
      expect(arguments['body'], 'Stretch your legs');
      expect(arguments['timeZoneName'], _kTimezoneId);

      final platformSpecifics = Map<Object?, Object?>.from(
        arguments['platformSpecifics']! as Map,
      );
      expect(platformSpecifics['channelId'], 'reminders');
      expect(platformSpecifics['channelName'], 'Reminders');
      expect(platformSpecifics['channelDescription'], 'User-set reminders');
    });

    test('schedules the given duration from now in local time', () async {
      await RemindMe.instance.init();
      final before = tz.TZDateTime.now(tz.local);

      await RemindMe.instance.scheduleInMinutes(
        title: 'Tea',
        body: 'Take the pot off',
        duration: const Duration(minutes: 10),
      );

      final after = tz.TZDateTime.now(tz.local);
      final call = callNamed(notificationCalls, 'zonedSchedule');
      final arguments = Map<Object?, Object?>.from(call.arguments as Map);
      final scheduled = DateTime.parse(
        arguments['scheduledDateTimeISO8601']! as String,
      );

      expect(
        scheduled.isBefore(before.add(const Duration(minutes: 10))),
        isFalse,
      );
      expect(
        scheduled.isAfter(after.add(const Duration(minutes: 10))),
        isFalse,
      );
    });

    test('returns a 31-bit id', () async {
      await RemindMe.instance.init();

      final id = await RemindMe.instance.scheduleInMinutes(
        title: 'Laundry',
        body: 'Move it to the dryer',
      );

      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThan(1 << 31));
    });

    test('asserts on durations of 24 hours or more', () async {
      await RemindMe.instance.init();

      await expectLater(
        RemindMe.instance.scheduleInMinutes(
          title: 'Too far out',
          body: 'Never sent',
          duration: const Duration(hours: 24),
        ),
        throwsAssertionError,
      );
      expect(wasCalled(notificationCalls, 'zonedSchedule'), isFalse);
    });
  });

  group('cancel', () {
    test('cancels the notification with the given id', () async {
      await RemindMe.instance.cancel(42);

      final call = callNamed(notificationCalls, 'cancel');
      final arguments = Map<Object?, Object?>.from(call.arguments as Map);

      expect(arguments['id'], 42);
      // Optional: you can also verify the tag is null if you want to be thorough
      // expect(arguments['tag'], isNull);
    });
  });
}
