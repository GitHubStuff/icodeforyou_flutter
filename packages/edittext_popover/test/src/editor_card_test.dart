// test/src/editor_card_test.dart
import 'package:edittext_popover/src/_editor_card.dart';
import 'package:edittext_popover/src/_editor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorCard', () {
    testWidgets('renders all child components', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: EditorCard(
                textController: controller,
                focusNode: focusNode,
                textStyle: const TextStyle(fontSize: 18),
                saveWidget: const Text('SAVE'),
                cancelWidget: const Text('CANCEL'),
                onSave: () {},
                onCancel: () {},
                textFieldHeight: 200,
              ),
            ),
          ),
        ),
      );

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('ln:'), findsOneWidget);

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
              child: EditorCard(
                textController: controller,
                focusNode: focusNode,
                textStyle: const TextStyle(fontSize: 18),
                saveWidget: const Text('SAVE'),
                cancelWidget: const Text('CANCEL'),
                onSave: () => saveCalled = true,
                onCancel: () {},
                textFieldHeight: 200,
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
              child: EditorCard(
                textController: controller,
                focusNode: focusNode,
                textStyle: const TextStyle(fontSize: 18),
                saveWidget: const Text('SAVE'),
                cancelWidget: const Text('CANCEL'),
                onSave: () {},
                onCancel: () => cancelCalled = true,
                textFieldHeight: 200,
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

    testWidgets('updates stats when text changes', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: EditorCard(
                textController: controller,
                focusNode: focusNode,
                textStyle: const TextStyle(fontSize: 18),
                saveWidget: const Text('SAVE'),
                cancelWidget: const Text('CANCEL'),
                onSave: () {},
                onCancel: () {},
                textFieldHeight: 200,
              ),
            ),
          ),
        ),
      );

      expect(find.text('ln: 0  ch: 0'), findsOneWidget);

      cubit.updateText('hello');
      await tester.pump();

      expect(find.text('ln: 1  ch: 5'), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });

    testWidgets('uses theme colors for card', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      final cubit = EditorScreenCubit(initialText: '');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          ),
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: EditorCard(
                textController: controller,
                focusNode: focusNode,
                textStyle: const TextStyle(fontSize: 18),
                saveWidget: const Text('SAVE'),
                cancelWidget: const Text('CANCEL'),
                onSave: () {},
                onCancel: () {},
                textFieldHeight: 200,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);

      controller.dispose();
      focusNode.dispose();
      await cubit.close();
    });
  });
}
