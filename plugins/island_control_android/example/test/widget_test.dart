import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_control_android/island_control_android.dart';
import 'package:island_control_android_example/main.dart';

void main() {
  const channel = MethodChannel('island_control_android');
  late List<MethodCall> calls;

  setUp(() {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('starts with the island hidden', (tester) async {
    await tester.pumpWidget(ExampleApp(islandControl: IslandControlAndroid()));

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(calls, isEmpty);
  });

  testWidgets('flipping the switch shows then hides the island', (
    tester,
  ) async {
    await tester.pumpWidget(ExampleApp(islandControl: IslandControlAndroid()));

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(calls, hasLength(1));
    expect(calls.single.method, 'setIsland');
    expect(calls.single.arguments, <String, Object>{'isHidden': false});

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(calls, hasLength(2));
    expect(calls.last.arguments, <String, Object>{'isHidden': true});
  });
}
