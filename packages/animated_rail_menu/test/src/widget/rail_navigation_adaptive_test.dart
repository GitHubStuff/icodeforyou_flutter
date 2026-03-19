// test/src/widget/rail_navigation_adaptive_test.dart

import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Page extends StatelessWidget {
  const _Page({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}

const _entries = <RailMenuEntry>[
  RailMenuEntry(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
    page: _Page(label: 'Home Page'),
  ),
  RailMenuEntry(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
    label: 'Settings',
    page: _Page(label: 'Settings Page'),
  ),
];

Widget _build() => const MaterialApp(
      home: RailNavigationWidget(
        direction: RailDirection.adaptive,
        entries: _entries,
        transitionDuration: Duration.zero,
      ),
    );

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  group('RailDirection.adaptive — phone portrait (390×844)', () {
    testWidgets('uses horizontal scaffold', (tester) async {
      _setSize(tester, const Size(390, 844));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(
        find.byKey(RailNavigationWidget.horizontalScaffoldKey),
        findsOneWidget,
      );
    });

    testWidgets('renders first page', (tester) async {
      _setSize(tester, const Size(390, 844));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('tapping entry navigates', (tester) async {
      _setSize(tester, const Size(390, 844));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      await tester.tap(find.text('Settings'));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });

  group('RailDirection.adaptive — phone landscape (844×390)', () {
    testWidgets('uses vertical scaffold', (tester) async {
      _setSize(tester, const Size(844, 390));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(
        find.byKey(RailNavigationWidget.verticalScaffoldKey),
        findsOneWidget,
      );
    });

    testWidgets('renders first page', (tester) async {
      _setSize(tester, const Size(844, 390));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('tapping entry navigates', (tester) async {
      _setSize(tester, const Size(844, 390));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      await tester.tap(find.text('Settings'));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });

  group('RailDirection.adaptive — tablet portrait (744×1133)', () {
    testWidgets('uses vertical scaffold', (tester) async {
      _setSize(tester, const Size(744, 1133));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(
        find.byKey(RailNavigationWidget.verticalScaffoldKey),
        findsOneWidget,
      );
    });

    testWidgets('renders first page', (tester) async {
      _setSize(tester, const Size(744, 1133));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('tapping entry navigates', (tester) async {
      _setSize(tester, const Size(744, 1133));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      await tester.tap(find.text('Settings'));
      await _pump(tester);
      expect(find.text('Settings Page'), findsOneWidget);
    });
  });

  group('RailDirection.adaptive — tablet landscape (1133×744)', () {
    testWidgets('uses vertical scaffold', (tester) async {
      _setSize(tester, const Size(1133, 744));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(
        find.byKey(RailNavigationWidget.verticalScaffoldKey),
        findsOneWidget,
      );
    });

    testWidgets('renders first page', (tester) async {
      _setSize(tester, const Size(1133, 744));
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(_build());
      await _pump(tester);
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
