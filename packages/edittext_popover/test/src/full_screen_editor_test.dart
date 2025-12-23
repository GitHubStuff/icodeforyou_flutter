// test/src/full_screen_editor_test.dart
import 'package:edittext_popover/src/_editor_cubit.dart';
import 'package:edittext_popover/src/_full_screen_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FullScreenEditor', () {
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
                  FullScreenEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    safeArea: EdgeInsets.zero,
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

    testWidgets('respects safe area insets', (tester) async {
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
                  FullScreenEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    safeArea: const EdgeInsets.only(top: 44, bottom: 34),
                    viewInsets: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.top, equals(44));

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('respects view insets for keyboard', (tester) async {
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
                  FullScreenEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () {},
                    safeArea: EdgeInsets.zero,
                    viewInsets: const EdgeInsets.only(bottom: 300),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.bottom, equals(300));

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
                  FullScreenEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () => saveCalled = true,
                    onCancel: () {},
                    safeArea: EdgeInsets.zero,
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
                  FullScreenEditor(
                    textController: controller,
                    focusNode: focusNode,
                    textStyle: const TextStyle(fontSize: 18),
                    saveWidget: const Text('SAVE'),
                    cancelWidget: const Text('CANCEL'),
                    onSave: () {},
                    onCancel: () => cancelCalled = true,
                    safeArea: EdgeInsets.zero,
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
