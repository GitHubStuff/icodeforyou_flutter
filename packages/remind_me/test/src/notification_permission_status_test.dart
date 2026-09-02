// packages/remind_me/test/src/notification_permission_status_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:remind_me/src/notification_permission_status.dart';

void main() {
  group('NotificationPermissionStatus', () {
    test('defines exactly the five permission states', () {
      expect(
        NotificationPermissionStatus.values,
        const [
          NotificationPermissionStatus.granted,
          NotificationPermissionStatus.denied,
          NotificationPermissionStatus.permanentlyDenied,
          NotificationPermissionStatus.restricted,
          NotificationPermissionStatus.notDetermined,
        ],
      );
    });

    test('has stable names for UI switch statements', () {
      expect(NotificationPermissionStatus.granted.name, 'granted');
      expect(NotificationPermissionStatus.denied.name, 'denied');
      expect(
        NotificationPermissionStatus.permanentlyDenied.name,
        'permanentlyDenied',
      );
      expect(NotificationPermissionStatus.restricted.name, 'restricted');
      expect(NotificationPermissionStatus.notDetermined.name, 'notDetermined');
    });
  });
}
