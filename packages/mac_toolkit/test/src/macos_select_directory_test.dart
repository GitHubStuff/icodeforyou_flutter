// packages/tool_kit/test/src/macos_select_directory_test.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/macos_select_directory.dart'
    show DirectoryPickerFn, MacOSSelectDirectory;

void main() {
  const String buttonLabel = 'Choose folder';
  const String dialogTitle = 'Pick a folder';
  const String pickedPath = '/Users/test/Documents';

  Future<void> pumpSubject(
    WidgetTester tester, {
    required ValueChanged<Directory> onDirectorySelected,
    VoidCallback? onCancel,
    String? initialDirectory,
    bool Function()? isMacOSOverride,
    String Function()? operatingSystemOverride,
    DirectoryPickerFn? pickerOverride,
  }) {
    return tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: MacOSSelectDirectory(
            onDirectorySelected: onDirectorySelected,
            onCancel: onCancel,
            buttonLabel: buttonLabel,
            dialogTitle: dialogTitle,
            initialDirectory: initialDirectory,
            isMacOSOverride: isMacOSOverride,
            operatingSystemOverride: operatingSystemOverride,
            pickerOverride: pickerOverride,
          ),
        ),
      ),
    );
  }

  Future<void> tapButton(WidgetTester tester) async {
    await tester.tap(find.byType(CupertinoButton));
    await tester.pump();
  }

  group('MacOSSelectDirectory', () {
    group('rendering', () {
      testWidgets('shows the button label and folder icon', (tester) async {
        await pumpSubject(
          tester,
          onDirectorySelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride: ({dialogTitle, initialDirectory}) async => null,
        );

        expect(find.text(buttonLabel), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.folder), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      });

      testWidgets('does not show a path before any selection', (tester) async {
        await pumpSubject(
          tester,
          onDirectorySelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride: ({dialogTitle, initialDirectory}) async => null,
        );

        expect(find.text(pickedPath), findsNothing);
      });
    });

    group('platform guard', () {
      testWidgets(
        'throws UnsupportedError with the overridden OS name off macOS',
        (tester) async {
          await pumpSubject(
            tester,
            onDirectorySelected: (_) {},
            isMacOSOverride: () => false,
            operatingSystemOverride: () => 'windows',
            pickerOverride: ({dialogTitle, initialDirectory}) async =>
                pickedPath,
          );

          await tapButton(tester);

          final Object? exception = tester.takeException();
          expect(exception, isA<UnsupportedError>());
          expect(
            (exception! as UnsupportedError).message,
            contains('not platform: windows'),
          );
        },
      );

      testWidgets(
        'falls back to Platform.operatingSystem when no OS override is given',
        (tester) async {
          await pumpSubject(
            tester,
            onDirectorySelected: (_) {},
            isMacOSOverride: () => false,
            pickerOverride: ({dialogTitle, initialDirectory}) async =>
                pickedPath,
          );

          await tapButton(tester);

          final Object? exception = tester.takeException();
          expect(exception, isA<UnsupportedError>());
          expect(
            (exception! as UnsupportedError).message,
            contains('not platform: ${Platform.operatingSystem}'),
          );
        },
      );

      testWidgets(
        'falls back to Platform.isMacOS and runs the picker on a macOS host',
        (tester) async {
          bool pickerCalled = false;

          await pumpSubject(
            tester,
            onDirectorySelected: (_) {},
            pickerOverride: ({dialogTitle, initialDirectory}) async {
              pickerCalled = true;
              return pickedPath;
            },
          );

          await tapButton(tester);
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(pickerCalled, isTrue);
        },
        skip: !Platform.isMacOS,
      );

      testWidgets(
        'falls back to Platform.isMacOS and throws on a non-macOS host',
        (tester) async {
          bool pickerCalled = false;

          await pumpSubject(
            tester,
            onDirectorySelected: (_) {},
            pickerOverride: ({dialogTitle, initialDirectory}) async {
              pickerCalled = true;
              return pickedPath;
            },
          );

          await tapButton(tester);

          expect(tester.takeException(), isA<UnsupportedError>());
          expect(pickerCalled, isFalse);
        },
        skip: Platform.isMacOS,
      );
    });

    group('picking', () {
      testWidgets('passes dialogTitle and initialDirectory to the picker', (
        tester,
      ) async {
        String? receivedTitle;
        String? receivedInitialDirectory;

        await pumpSubject(
          tester,
          onDirectorySelected: (_) {},
          initialDirectory: '/initial',
          isMacOSOverride: () => true,
          pickerOverride: ({dialogTitle, initialDirectory}) async {
            receivedTitle = dialogTitle;
            receivedInitialDirectory = initialDirectory;
            return pickedPath;
          },
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(receivedTitle, dialogTitle);
        expect(receivedInitialDirectory, '/initial');
      });

      testWidgets('shows a spinner and disables the button while picking', (
        tester,
      ) async {
        final Completer<String?> completer = Completer<String?>();

        await pumpSubject(
          tester,
          onDirectorySelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride: ({dialogTitle, initialDirectory}) => completer.future,
        );

        await tapButton(tester);

        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.text(buttonLabel), findsNothing);
        final CupertinoButton button = tester.widget<CupertinoButton>(
          find.byType(CupertinoButton),
        );
        expect(button.onPressed, isNull);

        completer.complete(pickedPath);
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoActivityIndicator), findsNothing);
        expect(find.text(buttonLabel), findsOneWidget);
      });

      testWidgets(
        'invokes onDirectorySelected with the picked Directory and shows path',
        (tester) async {
          Directory? selected;

          await pumpSubject(
            tester,
            onDirectorySelected: (Directory directory) => selected = directory,
            isMacOSOverride: () => true,
            pickerOverride: ({dialogTitle, initialDirectory}) async =>
                pickedPath,
          );

          await tapButton(tester);
          await tester.pumpAndSettle();

          expect(selected, isNotNull);
          expect(selected!.path, pickedPath);
          expect(find.text(pickedPath), findsOneWidget);
        },
      );

      testWidgets('invokes onCancel when the picker returns null', (
        tester,
      ) async {
        bool cancelled = false;
        bool selectedCalled = false;

        await pumpSubject(
          tester,
          onDirectorySelected: (_) => selectedCalled = true,
          onCancel: () => cancelled = true,
          isMacOSOverride: () => true,
          pickerOverride: ({dialogTitle, initialDirectory}) async => null,
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(cancelled, isTrue);
        expect(selectedCalled, isFalse);
        expect(find.text(pickedPath), findsNothing);
      });

      testWidgets('tolerates a null onCancel when the picker returns null', (
        tester,
      ) async {
        await pumpSubject(
          tester,
          onDirectorySelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride: ({dialogTitle, initialDirectory}) async => null,
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('does nothing when unmounted while the picker is open', (
        tester,
      ) async {
        final Completer<String?> completer = Completer<String?>();
        bool selectedCalled = false;
        bool cancelled = false;

        await pumpSubject(
          tester,
          onDirectorySelected: (_) => selectedCalled = true,
          onCancel: () => cancelled = true,
          isMacOSOverride: () => true,
          pickerOverride: ({dialogTitle, initialDirectory}) => completer.future,
        );

        await tapButton(tester);

        // Replace the tree so the widget is disposed mid-pick.
        await tester.pumpWidget(const CupertinoApp(home: SizedBox()));

        completer.complete(pickedPath);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(selectedCalled, isFalse);
        expect(cancelled, isFalse);
      });
    });
  });
}
