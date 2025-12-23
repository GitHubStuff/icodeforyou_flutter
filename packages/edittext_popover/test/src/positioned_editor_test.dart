// test/src/positioned_editor_test.dart
import 'package:edittext_popover/src/_editor_cubit.dart';
import 'package:edittext_popover/src/_positioned_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PositionedEditor', () {
    testWidgets('renders editor card', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Stack(
                children: [
                  PositionedEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    targetRect: null,
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('positions relative to targetRect', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Stack(
                children: [
                  PositionedEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    targetRect: const Rect.fromLTWH(100, 100, 200, 50),
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, equals(100));
      expect(positioned.top, equals(158));

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('clamps position when overflowing right edge', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Stack(
                children: [
                  PositionedEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    targetRect: const Rect.fromLTWH(600, 100, 200, 50),
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, lessThan(600));

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('clamps position when overflowing left edge', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Stack(
                children: [
                  PositionedEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    targetRect: const Rect.fromLTWH(-100, 100, 50, 50),
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, equals(16));

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('positions above target when bottom overflow', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Stack(
                children: [
                  PositionedEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    targetRect: const Rect.fromLTWH(100, 500, 200, 50),
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.top, lessThan(500));

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('calls onSave when save tapped', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');
      var saveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Stack(
                children: [
                  PositionedEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () => saveCalled = true,
                    onCancel: () {},
                    targetRect: null,
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SAVE'));
      await tester.pump();

      expect(saveCalled, isTrue);

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('calls onCancel when cancel tapped', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');
      var cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: Stack(
                children: [
                  PositionedEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () => cancelCalled = true,
                    targetRect: null,
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('CANCEL'));
      await tester.pump();

      expect(cancelCalled, isTrue);

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });
  });
}
