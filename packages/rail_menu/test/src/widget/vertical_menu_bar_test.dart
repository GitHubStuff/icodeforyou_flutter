// test/src/widget/vertical_menu_bar_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rail_menu/rail_menu.dart';

List<RailMenuItem> _items(int count) => List.generate(
      count,
      (i) => RailMenuItem(child: Text('$i')),
    );

Widget _buildVertical({
  required List<RailMenuItem> items,
  RailMenuDirection direction = RailMenuDirection.left,
  int? limit,
  int defaultIndex = 0,
}) =>
    MaterialApp(
      home: BlocProvider(
        create: (_) => RailMenuCubit(defaultIndex: defaultIndex),
        child: Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 72,
                child: RailMenu(
                  direction: direction,
                  items: items,
                  limit: limit,
                  activeColor: Colors.blue,
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );

void main() {
  group('_VerticalMenuBar overflow', () {
    testWidgets('shows More button when limit forces vertical overflow',
        (tester) async {
      await tester.pumpWidget(
        _buildVertical(items: _items(5), limit: 4),
      );
      await tester.pump();
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('More button is active when overflow item is active',
        (tester) async {
      await tester.pumpWidget(
        _buildVertical(items: _items(5), limit: 4, defaultIndex: 4),
      );
      await tester.pump();
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('tapping vertical More opens modal with all items',
        (tester) async {
      await tester.pumpWidget(
        _buildVertical(items: _items(5), limit: 4),
      );
      await tester.pump();
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('direction right also shows More button with overflow',
        (tester) async {
      await tester.pumpWidget(
        _buildVertical(
          items: _items(5),
          limit: 4,
          direction: RailMenuDirection.right,
        ),
      );
      await tester.pump();
      expect(find.text('More'), findsOneWidget);
    });
  });
}
