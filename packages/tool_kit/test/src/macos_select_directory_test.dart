// packages/tool_kit/test/src/macos_select_directory_test.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tool_kit/src/macos_select_directory.dart';

void main() {
  Widget buildTestWidget({
    required ValueChanged<Directory> onDirectorySelected,
    VoidCallback? onCancel,
    String buttonLabel = 'Select Folder',
    String dialogTitle = 'Choose Folder',
    String? initialDirectory,
    bool Function()? isMacOSOverride,
    String Function()? operatingSystemOverride,
    DirectoryPickerFn? pickerOverride,
  }) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        child: MacOSSelectDirectory(
          onDirectorySelected: onDirectorySelected,
          buttonLabel: buttonLabel,
          dialogTitle: dialogTitle,
          initialDirectory: initialDirectory,
          onCancel: onCancel,
          isMacOSOverride: isMacOSOverride ?? () => true,
          operatingSystemOverride: operatingSystemOverride ?? () => 'macos',
          pickerOverride: pickerOverride,
        ),
      ),
    );
  }

  testWidgets('throws UnsupportedError when run on non-macOS', (
    WidgetTester tester,
  ) async {
    Object? capturedError;

    await runZonedGuarded(
      () async {
        await tester.pumpWidget(
          buildTestWidget(
            onDirectorySelected: (_) {},
            isMacOSOverride: () => false,
            operatingSystemOverride: () => 'windows',
          ),
        );

        await tester.tap(find.byType(CupertinoButton));
        await tester.pump();
      },
      (error, stack) {
        capturedError = error;
      },
    );

    expect(capturedError, isA<UnsupportedError>());
    expect(
      (capturedError! as UnsupportedError).message,
      contains(
        'MacOSSelectDirectory is only supported on macOS. '
        'Current platform: windows',
      ),
    );
  });

  testWidgets(
    'selects folder and triggers callback with Directory',
    (WidgetTester tester) async {
      Directory? chosenDir;
      String? passedTitle;
      String? passedInitialDir;

      await tester.pumpWidget(
        buildTestWidget(
          buttonLabel: 'Select Projects',
          dialogTitle: 'Pick Projects Folder',
          initialDirectory: '/Users/test/dev',
          onDirectorySelected: (dir) => chosenDir = dir,
          pickerOverride: ({dialogTitle, initialDirectory}) async {
            passedTitle = dialogTitle;
            passedInitialDir = initialDirectory;
            return '/Users/test/dev/my_project';
          },
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pumpAndSettle();

      expect(passedTitle, equals('Pick Projects Folder'));
      expect(passedInitialDir, equals('/Users/test/dev'));
      expect(chosenDir, isNotNull);
      expect(chosenDir!.path, equals('/Users/test/dev/my_project'));
      expect(find.text('/Users/test/dev/my_project'), findsOneWidget);
    },
  );

  testWidgets(
    'triggers onCancel callback when user cancels folder selection',
    (WidgetTester tester) async {
      bool canceled = false;

      await tester.pumpWidget(
        buildTestWidget(
          onDirectorySelected: (_) {},
          onCancel: () => canceled = true,
          pickerOverride: ({dialogTitle, initialDirectory}) async {
            return null;
          },
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pumpAndSettle();

      expect(canceled, isTrue);
    },
  );

  testWidgets(
    'handles cancellation gracefully when onCancel is null',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          onDirectorySelected: (_) {},
          onCancel: null,
          pickerOverride: ({dialogTitle, initialDirectory}) async {
            return null;
          },
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoButton), findsOneWidget);
    },
  );

  testWidgets('renders default widget using fallback parameters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: MacOSSelectDirectory(
            onDirectorySelected: (_) {},
            buttonLabel: 'Default Label',
            dialogTitle: 'Default Dialog',
          ),
        ),
      ),
    );

    expect(find.text('Default Label'), findsOneWidget);
  });
}
