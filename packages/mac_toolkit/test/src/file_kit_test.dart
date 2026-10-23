// packages/tool_kit/test/src/file_kit_test.dart
import 'dart:io';

import 'package:test/test.dart';
import '../../lib/tool_kit.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_kit_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  File tempFile(String name) => File('${tempDir.path}/$name');

  group('FileKit', () {
    group('constructor', () {
      test('defaults isMacOSOverride to Platform.isMacOS', () {
        final FileKit kit = FileKit();

        expect(kit.isMacOSOverride(), Platform.isMacOS);
      });

      test('defaults operatingSystemOverride to Platform.operatingSystem', () {
        final FileKit kit = FileKit();

        expect(kit.operatingSystemOverride(), Platform.operatingSystem);
      });

      test('uses supplied overrides', () {
        final FileKit kit = FileKit(
          isMacOSOverride: () => false,
          operatingSystemOverride: () => 'haiku',
        );

        expect(kit.isMacOSOverride(), isFalse);
        expect(kit.operatingSystemOverride(), 'haiku');
      });
    });

    group('areFilesIdentical', () {
      test('returns false when the first file does not exist', () async {
        final File existing = tempFile('a.txt')..writeAsStringSync('hello');
        final File missing = tempFile('missing.txt');

        final bool result = await FileKit().areFilesIdentical(
          missing,
          existing,
        );

        expect(result, isFalse);
      });

      test('returns false when the second file does not exist', () async {
        final File existing = tempFile('a.txt')..writeAsStringSync('hello');
        final File missing = tempFile('missing.txt');

        final bool result = await FileKit().areFilesIdentical(
          existing,
          missing,
        );

        expect(result, isFalse);
      });

      test('returns false when byte lengths differ', () async {
        final File short = tempFile('short.txt')..writeAsStringSync('hi');
        final File long = tempFile('long.txt')..writeAsStringSync('hello');

        final bool result = await FileKit().areFilesIdentical(short, long);

        expect(result, isFalse);
      });

      test('returns false when lengths match but contents differ', () async {
        final File first = tempFile('first.txt')..writeAsStringSync('abcde');
        final File second = tempFile('second.txt')..writeAsStringSync('abcdx');

        final bool result = await FileKit().areFilesIdentical(first, second);

        expect(result, isFalse);
      });

      test('returns true when contents are byte-for-byte identical', () async {
        final File first = tempFile('first.txt')..writeAsStringSync('abcde');
        final File second = tempFile('second.txt')..writeAsStringSync('abcde');

        final bool result = await FileKit().areFilesIdentical(first, second);

        expect(result, isTrue);
      });

      test('returns true when comparing a file with itself', () async {
        final File file = tempFile('self.txt')..writeAsStringSync('same');

        final bool result = await FileKit().areFilesIdentical(file, file);

        expect(result, isTrue);
      });

      test('returns true for two empty files', () async {
        final File first = tempFile('empty1.txt')..writeAsStringSync('');
        final File second = tempFile('empty2.txt')..writeAsStringSync('');

        final bool result = await FileKit().areFilesIdentical(first, second);

        expect(result, isTrue);
      });
    });

    group('compareViaMacOsCmp', () {
      test('throws UnsupportedError with the overridden platform name', () {
        final FileKit kit = FileKit(
          isMacOSOverride: () => false,
          operatingSystemOverride: () => 'windows',
        );

        expect(
          () => kit.compareViaMacOsCmp('a', 'b'),
          throwsA(
            isA<UnsupportedError>().having(
              (UnsupportedError e) => e.message,
              'message',
              contains('Current platform: windows'),
            ),
          ),
        );
      });

      test(
        'throws UnsupportedError reporting Platform.operatingSystem when no '
        'operatingSystemOverride is supplied',
        () {
          final FileKit kit = FileKit(isMacOSOverride: () => false);

          expect(
            () => kit.compareViaMacOsCmp('a', 'b'),
            throwsA(
              isA<UnsupportedError>().having(
                (UnsupportedError e) => e.message,
                'message',
                contains('Current platform: ${Platform.operatingSystem}'),
              ),
            ),
          );
        },
      );

      test('returns true when cmp reports identical files', () async {
        final File first = tempFile('first.txt')..writeAsStringSync('abcde');
        final File second = tempFile('second.txt')..writeAsStringSync('abcde');
        final FileKit kit = FileKit(isMacOSOverride: () => true);

        final bool result = await kit.compareViaMacOsCmp(
          first.path,
          second.path,
        );

        expect(result, isTrue);
      });

      test('returns false when cmp reports differing files', () async {
        final File first = tempFile('first.txt')..writeAsStringSync('abcde');
        final File second = tempFile('second.txt')..writeAsStringSync('abcdx');
        final FileKit kit = FileKit(isMacOSOverride: () => true);

        final bool result = await kit.compareViaMacOsCmp(
          first.path,
          second.path,
        );

        expect(result, isFalse);
      });

      test('returns false when a path does not exist', () async {
        final File existing = tempFile('a.txt')..writeAsStringSync('hello');
        final FileKit kit = FileKit(isMacOSOverride: () => true);

        final bool result = await kit.compareViaMacOsCmp(
          existing.path,
          tempFile('missing.txt').path,
        );

        expect(result, isFalse);
      });
    });
  });
}
