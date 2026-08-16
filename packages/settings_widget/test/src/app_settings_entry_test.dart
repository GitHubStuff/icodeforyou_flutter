// packages/settings_widget/test/src/app_settings_entry_test.dart
//
// AppSettingsEntry declares no members, so the only executable line is
// its const constructor. Const invocations are canonicalized at compile
// time and never hit the constructor at runtime, so the subclass below
// is deliberately instantiated WITHOUT `const`.
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_widget/src/app_settings_entry.dart';

final class _ProbeEntry extends AppSettingsEntry {
  const _ProbeEntry();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  group('AppSettingsEntry', () {
    test('subclasses construct through the base const constructor', () {
      final entry = _ProbeEntry();

      expect(entry, isA<AppSettingsEntry>());
      expect(entry, isA<StatelessWidget>());
      expect(entry.key, isNull);
    });

    testWidgets('subclasses render as ordinary stateless widgets', (
      tester,
    ) async {
      await tester.pumpWidget(_ProbeEntry());

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
