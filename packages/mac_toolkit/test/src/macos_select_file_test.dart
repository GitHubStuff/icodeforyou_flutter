// packages/tool_kit/test/src/macos_select_file_test.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/macos_select_file.dart'
    show FilePickerFn, MacOSSelectFile;

/// Minimal concrete [PlatformFile] for tests.
///
/// [PlatformFile] is `abstract base`, so it must be extended rather than
/// instantiated or implemented. Only [name] and [path] are consulted by
/// [MacOSSelectFile]; everything else is stubbed.
final class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile({required this.name, this.path});

  @override
  final String name;

  @override
  final String? path;

  @override
  Uri get uri => Uri.file(path ?? name);

  @override
  Never get xFile => throw UnimplementedError('xFile is not used in tests');

  @override
  Future<int> length() async => 0;

  @override
  int? lengthSync() => 0;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Stream<Uint8List> readAsByteStream() => const Stream<Uint8List>.empty();
}

void main() {
  const String buttonLabel = 'Choose file';
  const String dialogTitle = 'Pick a file';
  const String pickedPath = '/Users/test/Documents/notes.txt';
  const String hiddenPath = '/Users/test/Documents/.secret';

  PlatformFile visibleFile() =>
      _FakePlatformFile(name: 'notes.txt', path: pickedPath);

  PlatformFile hiddenFile() =>
      _FakePlatformFile(name: '.secret', path: hiddenPath);

  PlatformFile pathlessFile() => _FakePlatformFile(name: 'notes.txt');

  Future<void> pumpSubject(
    WidgetTester tester, {
    required ValueChanged<String> onFileSelected,
    VoidCallback? onCancel,
    List<String>? allowedExtensions,
    bool includeHidden = false,
    bool Function()? isMacOSOverride,
    String Function()? operatingSystemOverride,
    FilePickerFn? pickerOverride,
  }) {
    return tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: MacOSSelectFile(
            onFileSelected: onFileSelected,
            onCancel: onCancel,
            buttonLabel: buttonLabel,
            dialogTitle: dialogTitle,
            allowedExtensions: allowedExtensions,
            includeHidden: includeHidden,
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

  group('MacOSSelectFile', () {
    group('rendering', () {
      testWidgets('shows the button label and folder icon', (tester) async {
        await pumpSubject(
          tester,
          onFileSelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  null,
        );

        expect(find.text(buttonLabel), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.folder), findsOneWidget);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      });

      testWidgets('does not show a path before any selection', (tester) async {
        await pumpSubject(
          tester,
          onFileSelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  null,
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
            onFileSelected: (_) {},
            isMacOSOverride: () => false,
            operatingSystemOverride: () => 'windows',
            pickerOverride:
                ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                    visibleFile(),
          );

          await tapButton(tester);

          final Object? exception = tester.takeException();
          expect(exception, isA<UnsupportedError>());
          expect(
            (exception! as UnsupportedError).message,
            contains('Current platform: windows'),
          );
        },
      );

      testWidgets(
        'falls back to Platform.operatingSystem when no OS override is given',
        (tester) async {
          await pumpSubject(
            tester,
            onFileSelected: (_) {},
            isMacOSOverride: () => false,
            pickerOverride:
                ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                    visibleFile(),
          );

          await tapButton(tester);

          final Object? exception = tester.takeException();
          expect(exception, isA<UnsupportedError>());
          expect(
            (exception! as UnsupportedError).message,
            contains('Current platform: ${Platform.operatingSystem}'),
          );
        },
      );

      testWidgets(
        'falls back to Platform.isMacOS and runs the picker on a macOS host',
        (tester) async {
          bool pickerCalled = false;

          await pumpSubject(
            tester,
            onFileSelected: (_) {},
            pickerOverride:
                ({dialogTitle, type = FileType.any, allowedExtensions}) async {
                  pickerCalled = true;
                  return visibleFile();
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
            onFileSelected: (_) {},
            pickerOverride:
                ({dialogTitle, type = FileType.any, allowedExtensions}) async {
                  pickerCalled = true;
                  return visibleFile();
                },
          );

          await tapButton(tester);

          expect(tester.takeException(), isA<UnsupportedError>());
          expect(pickerCalled, isFalse);
        },
        skip: Platform.isMacOS,
      );
    });

    group('picker arguments', () {
      testWidgets('passes dialogTitle and FileType.any without extensions', (
        tester,
      ) async {
        String? receivedTitle;
        FileType? receivedType;
        List<String>? receivedExtensions;

        await pumpSubject(
          tester,
          onFileSelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async {
                receivedTitle = dialogTitle;
                receivedType = type;
                receivedExtensions = allowedExtensions;
                return visibleFile();
              },
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(receivedTitle, dialogTitle);
        expect(receivedType, FileType.any);
        expect(receivedExtensions, isNull);
      });

      testWidgets('passes FileType.custom with the allowed extensions', (
        tester,
      ) async {
        FileType? receivedType;
        List<String>? receivedExtensions;

        await pumpSubject(
          tester,
          onFileSelected: (_) {},
          allowedExtensions: const <String>['txt', 'pdf'],
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async {
                receivedType = type;
                receivedExtensions = allowedExtensions;
                return visibleFile();
              },
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(receivedType, FileType.custom);
        expect(receivedExtensions, <String>['txt', 'pdf']);
      });
    });

    group('picking', () {
      testWidgets('shows a spinner and disables the button while picking', (
        tester,
      ) async {
        final Completer<PlatformFile?> completer = Completer<PlatformFile?>();

        await pumpSubject(
          tester,
          onFileSelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) =>
                  completer.future,
        );

        await tapButton(tester);

        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
        expect(find.text(buttonLabel), findsNothing);
        final CupertinoButton button = tester.widget<CupertinoButton>(
          find.byType(CupertinoButton),
        );
        expect(button.onPressed, isNull);

        completer.complete(visibleFile());
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoActivityIndicator), findsNothing);
        expect(find.text(buttonLabel), findsOneWidget);
      });

      testWidgets('invokes onFileSelected with the path and shows it', (
        tester,
      ) async {
        String? selected;

        await pumpSubject(
          tester,
          onFileSelected: (String path) => selected = path,
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  visibleFile(),
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(selected, pickedPath);
        expect(find.text(pickedPath), findsOneWidget);
      });

      testWidgets('invokes onCancel when the picker returns null', (
        tester,
      ) async {
        bool cancelled = false;
        bool selectedCalled = false;

        await pumpSubject(
          tester,
          onFileSelected: (_) => selectedCalled = true,
          onCancel: () => cancelled = true,
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  null,
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
          onFileSelected: (_) {},
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  null,
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('ignores a file with a null path', (tester) async {
        bool selectedCalled = false;
        bool cancelled = false;

        await pumpSubject(
          tester,
          onFileSelected: (_) => selectedCalled = true,
          onCancel: () => cancelled = true,
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  pathlessFile(),
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(selectedCalled, isFalse);
        expect(cancelled, isFalse);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
      });

      testWidgets('does nothing when unmounted while the picker is open', (
        tester,
      ) async {
        final Completer<PlatformFile?> completer = Completer<PlatformFile?>();
        bool selectedCalled = false;
        bool cancelled = false;

        await pumpSubject(
          tester,
          onFileSelected: (_) => selectedCalled = true,
          onCancel: () => cancelled = true,
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) =>
                  completer.future,
        );

        await tapButton(tester);

        // Replace the tree so the widget is disposed mid-pick.
        await tester.pumpWidget(const CupertinoApp(home: SizedBox()));

        completer.complete(visibleFile());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(selectedCalled, isFalse);
        expect(cancelled, isFalse);
      });
    });

    group('hidden files', () {
      testWidgets('ignores hidden files by default', (tester) async {
        bool selectedCalled = false;

        await pumpSubject(
          tester,
          onFileSelected: (_) => selectedCalled = true,
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  hiddenFile(),
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(selectedCalled, isFalse);
        expect(find.text(hiddenPath), findsNothing);
      });

      testWidgets('accepts hidden files when includeHidden is true', (
        tester,
      ) async {
        String? selected;

        await pumpSubject(
          tester,
          onFileSelected: (String path) => selected = path,
          includeHidden: true,
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  hiddenFile(),
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(selected, hiddenPath);
        expect(find.text(hiddenPath), findsOneWidget);
      });

      testWidgets('still accepts visible files when includeHidden is true', (
        tester,
      ) async {
        String? selected;

        await pumpSubject(
          tester,
          onFileSelected: (String path) => selected = path,
          includeHidden: true,
          isMacOSOverride: () => true,
          pickerOverride:
              ({dialogTitle, type = FileType.any, allowedExtensions}) async =>
                  visibleFile(),
        );

        await tapButton(tester);
        await tester.pumpAndSettle();

        expect(selected, pickedPath);
      });
    });
  });
}
