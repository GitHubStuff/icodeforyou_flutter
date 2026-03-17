// test/src/widget/rail_menu_widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_menu/rail_menu.dart';

RailMenuItem _item({String label = 'A', VoidCallback? onTap}) => RailMenuItem(
      child: Text(label),
      onTap: onTap,
    );

List<RailMenuItem> _items(int count) =>
    List.generate(count, (i) => _item(label: '$i'));

Widget _buildSubject({
  required List<RailMenuItem> items,
  RailMenuDirection direction = RailMenuDirection.bottom,
  int? limit,
  int defaultIndex = 0,
}) =>
    MaterialApp(
      home: BlocProvider(
        create: (_) => RailMenuCubit(defaultIndex: defaultIndex),
        child: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: SizedBox(
            height: 64,
            child: RailMenu(
              direction: direction,
              items: items,
              limit: limit,
              activeColor: Colors.blue,
            ),
          ),
        ),
      ),
    );

void main() {
  group('RailMenu', () {
    testWidgets('renders visible items', (tester) async {
      await tester.pumpWidget(_buildSubject(items: _items(3)));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows More button when limit forces overflow', (tester) async {
      await tester.pumpWidget(
        _buildSubject(items: _items(5), limit: 4),
      );
      await tester.pump();
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('does not show More button when all items fit', (tester) async {
      await tester.pumpWidget(_buildSubject(items: _items(2)));
      await tester.pump();
      expect(find.text('More'), findsNothing);
    });

    testWidgets('renders with direction top', (tester) async {
      await tester.pumpWidget(
        _buildSubject(items: _items(2), direction: RailMenuDirection.top),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders with direction left', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => RailMenuCubit(),
            child: Scaffold(
              body: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: RailMenu(
                      direction: RailMenuDirection.left,
                      items: _items(2),
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders with direction right', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => RailMenuCubit(),
            child: Scaffold(
              body: Row(
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  SizedBox(
                    width: 64,
                    child: RailMenu(
                      direction: RailMenuDirection.right,
                      items: _items(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('tapping item calls onTap', (tester) async {
      var tapped = false;
      final items = [
        _item(label: 'A', onTap: () => tapped = true),
        _item(label: 'B'),
      ];
      await tester.pumpWidget(_buildSubject(items: items, defaultIndex: 1));
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('tapping active item is a no-op', (tester) async {
      var tapped = false;
      final items = [
        _item(label: 'A', onTap: () => tapped = true),
        _item(label: 'B'),
      ];
      await tester.pumpWidget(_buildSubject(items: items));
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('tapping More opens modal with all items', (tester) async {
      await tester.pumpWidget(_buildSubject(items: _items(5), limit: 4));
      await tester.pump();
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsWidgets);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('active item in modal shows checkmark', (tester) async {
      await tester.pumpWidget(
        _buildSubject(items: _items(5), limit: 4, defaultIndex: 0),
      );
      await tester.pump();
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('cancel widget closes modal', (tester) async {
      await tester.pumpWidget(_buildSubject(items: _items(5), limit: 4));
      await tester.pump();
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('tapping modal item calls onTap and closes modal',
        (tester) async {
      var tapped = false;
      final items = [
        _item(label: '0'),
        _item(label: '1'),
        _item(label: '2'),
        _item(label: '3'),
        _item(label: '4', onTap: () => tapped = true),
      ];
      await tester.pumpWidget(
        _buildSubject(items: items, limit: 4, defaultIndex: 0),
      );
      await tester.pump();
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('More button active indicator shown when overflow item active',
        (tester) async {
      await tester.pumpWidget(
        _buildSubject(items: _items(5), limit: 4, defaultIndex: 4),
      );
      await tester.pump();
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('item with enableHaptic false does not throw', (tester) async {
      final items = [
        const RailMenuItem(
          child: Text('A'),
          enableHaptic: false,
        ),
        _item(label: 'B'),
      ];
      await tester.pumpWidget(
        _buildSubject(items: items, defaultIndex: 1),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
    });

    testWidgets('item with null onTap does not throw on tap', (tester) async {
      final items = [
        const RailMenuItem(child: Text('A')),
        const RailMenuItem(child: Text('B')),
      ];
      await tester.pumpWidget(
        _buildSubject(items: items, defaultIndex: 1),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
    });

    testWidgets('renders with custom dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => RailMenuCubit(),
            child: Scaffold(
              bottomNavigationBar: SizedBox(
                height: 72,
                child: RailMenu(
                  direction: RailMenuDirection.bottom,
                  items: _items(2),
                  dimensions: const RailMenuDimensions.large(),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
    });

    // Covers _applyPixelFit overflow branch (lines 58-59 of
    // _overflow_calculator.dart). Sets a narrow screen width so that
    // 100 items at default itemExtent=56 cannot all fit, forcing overflow.
    testWidgets(
        'pixel-fit overflow — shows More button when items exceed available '
        'width with no limit', (tester) async {
      // Force a narrow logical width so pixel-fit triggers overflow.
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => RailMenuCubit(),
            child: Scaffold(
              bottomNavigationBar: SizedBox(
                height: 64,
                child: RailMenu(
                  direction: RailMenuDirection.bottom,
                  items: _items(100),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('More'), findsOneWidget);
    });
  });
}
