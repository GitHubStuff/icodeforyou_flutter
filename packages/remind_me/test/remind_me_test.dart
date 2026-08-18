// packages/remind_me/test/remind_me_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:remind_me/remind_me.dart';

void main() {
  group('remind_me barrel', () {
    test('exports the public API surface', () {
      expect(NotificationPermissionStatus.values, hasLength(5));
      expect(RemindMe, isA<Type>());
    });

    test('exposes the singleton through the barrel', () {
      expect(RemindMe.instance, isA<RemindMe>());
      expect(RemindMe.instance, same(RemindMe.instance));
    });
  });
}
