// packages/tool_kit/test/src/macos_select_file_test.dart
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tool_kit/src/macos_select_file.dart';

/// Concrete subtype of [PlatformFile] for test assertions.
final class _TestPlatformFile extends PlatformFile {
  _TestPlatformFile({
    required this.name,
    required this.size,
    this.path,
  });
  @override
  final String name;

  final int size;

  @override
  final String? path;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestWidget({
    required ValueChanged<String> onFileSelected,
    VoidCallback? onCancel,
    String buttonLabel = 'Choose File',
    String dialogTitle = 'Select File',
    List<String>? allowedExtensions,
    bool includeHidden = false,
    bool Function()? isMacOSOverride,
    String Function()? operatingSystemOverride,
    FilePickerFn? pickerOverride,
  }) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        child: MacOSSelectFile(
          onFileSelected: onFileSelected,
          onCancel: onCancel,
          buttonLabel: buttonLabel,
          dialogTitle: dialogTitle,
          allowedExtensions: allowedExtensions,
          includeHidden: includeHidden,
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

    // Use runZonedGuarded to capture async error thrown from onPressed
    await runZonedGuarded(
      () async {
        await tester.pumpWidget(
          buildTestWidget(
            onFileSelected: (_) {},
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
      (capturedError as UnsupportedError).message,
      contains(
        'MacOSSelectFile is only supported on macOS. Current platform: windows',
      ),
    );
  });

  testWidgets(
    'selects standard visible file and displays selected path',
    (WidgetTester tester) async {
      String? selected;
      FileType? receivedType;
      List<String>? receivedExtensions;

      final testFile = _TestPlatformFile(
        name: 'document.pdf',
        size: 1024,
        path: '/Users/test/document.pdf',
      );

      await tester.pumpWidget(
        buildTestWidget(
          onFileSelected: (path) => selected = path,
          allowedExtensions: const ['pdf'],
          pickerOverride:
              ({
                dialogTitle,
                type = FileType.any,
                allowedExtensions,
              }) async {
                receivedType = type;
                receivedExtensions = allowedExtensions;
                return testFile;
              },
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pumpAndSettle();

      expect(receivedType, equals(FileType.custom));
      expect(receivedExtensions, equals(['pdf']));
      expect(selected, equals('/Users/test/document.pdf'));
      expect(find.text('/Users/test/document.pdf'), findsOneWidget);
    },
  );

  testWidgets(
    'uses FileType.any when allowedExtensions is null',
    (WidgetTester tester) async {
      FileType? receivedType;

      await tester.pumpWidget(
        buildTestWidget(
          onFileSelected: (_) {},
          allowedExtensions: null,
          pickerOverride:
              ({
                dialogTitle,
                type = FileType.any,
                allowedExtensions,
              }) async {
                receivedType = type;
                return null;
              },
        ),
      );

      await tester.tap(find.byType(CupertinoButton));
      await tester.pumpAndSettle();

      expect(receivedType, equals(FileType.any));
    },
  );

  testWidgets('triggers onCancel callback when picker returns null', (
    WidgetTester tester,
  ) async {
    bool canceled = false;

    await tester.pumpWidget(
      buildTestWidget(
        onFileSelected: (_) {},
        onCancel: () => canceled = true,
        pickerOverride:
            ({
              dialogTitle,
              type = FileType.any,
              allowedExtensions,
            }) async {
              return null;
            },
      ),
    );

    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();

    expect(canceled, isTrue);
  });

  testWidgets('handles picker returning null without onCancel provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        onFileSelected: (_) {},
        onCancel: null,
        pickerOverride:
            ({
              dialogTitle,
              type = FileType.any,
              allowedExtensions,
            }) async {
              return null;
            },
      ),
    );

    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoButton), findsOneWidget);
  });

  testWidgets('ignores hidden file when includeHidden is false', (
    WidgetTester tester,
  ) async {
    bool selected = false;

    final hiddenFile = _TestPlatformFile(
      name: '.profile',
      size: 512,
      path: '/Users/test/.profile',
    );

    await tester.pumpWidget(
      buildTestWidget(
        onFileSelected: (_) => selected = true,
        includeHidden: false,
        pickerOverride:
            ({
              dialogTitle,
              type = FileType.any,
              allowedExtensions,
            }) async {
              return hiddenFile;
            },
      ),
    );

    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();

    expect(selected, isFalse);
    expect(find.text('/Users/test/.profile'), findsNothing);
  });

  testWidgets('selects hidden file when includeHidden is true', (
    WidgetTester tester,
  ) async {
    String? selected;

    final hiddenFile = _TestPlatformFile(
      name: '.zshrc',
      size: 256,
      path: '/Users/test/.zshrc',
    );

    await tester.pumpWidget(
      buildTestWidget(
        onFileSelected: (path) => selected = path,
        includeHidden: true,
        pickerOverride:
            ({
              dialogTitle,
              type = FileType.any,
              allowedExtensions,
            }) async {
              return hiddenFile;
            },
      ),
    );

    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();

    expect(selected, equals('/Users/test/.zshrc'));
    expect(find.text('/Users/test/.zshrc'), findsOneWidget);
  });

  testWidgets('ignores file when path is null', (WidgetTester tester) async {
    bool selected = false;

    final noPathFile = _TestPlatformFile(name: 'in_memory.txt', size: 100);

    await tester.pumpWidget(
      buildTestWidget(
        onFileSelected: (_) => selected = true,
        pickerOverride:
            ({
              dialogTitle,
              type = FileType.any,
              allowedExtensions,
            }) async {
              return noPathFile;
            },
      ),
    );

    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();

    expect(selected, isFalse);
  });

  testWidgets('uses default platform and picker fallbacks', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: MacOSSelectFile(
            onFileSelected: (_) {},
            buttonLabel: 'Default Test',
            dialogTitle: 'Default Sheet',
          ),
        ),
      ),
    );

    expect(find.text('Default Test'), findsOneWidget);
  });
}
