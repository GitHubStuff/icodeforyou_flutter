// packages/tool_kit/test/src/file_kit_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tool_kit/src/file_kit.dart';

void main() {
  late FileKit fileKit;
  late Directory tempDir;

  setUp(() async {
    fileKit = FileKit();
    tempDir = await Directory.systemTemp.createTemp('file_kit_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  File createTempFile(String name, String content) {
    final file = File('${tempDir.path}/$name');
    file.writeAsStringSync(content);
    return file;
  }

  group('areFilesIdentical', () {
    test('returns false when file1 does not exist', () async {
      final file1 = File('${tempDir.path}/missing1.txt');
      final file2 = createTempFile('present2.txt', 'hello');

      final result = await fileKit.areFilesIdentical(file1, file2);

      expect(result, isFalse);
    });

    test('returns false when file2 does not exist', () async {
      final file1 = createTempFile('present1.txt', 'hello');
      final file2 = File('${tempDir.path}/missing2.txt');

      final result = await fileKit.areFilesIdentical(file1, file2);

      expect(result, isFalse);
    });

    test('returns false when both files have different lengths', () async {
      final file1 = createTempFile('short.txt', 'abc');
      final file2 = createTempFile('longer.txt', 'abcdef');

      final result = await fileKit.areFilesIdentical(file1, file2);

      expect(result, isFalse);
    });

    test(
      'returns false when files have same length but different contents',
      () async {
        final file1 = createTempFile('content_a.txt', 'abcd');
        final file2 = createTempFile('content_b.txt', 'abce');

        final result = await fileKit.areFilesIdentical(file1, file2);

        expect(result, isFalse);
      },
    );

    test('returns true when files have identical contents', () async {
      final file1 = createTempFile('identical_a.txt', 'same exact content');
      final file2 = createTempFile('identical_b.txt', 'same exact content');

      final result = await fileKit.areFilesIdentical(file1, file2);

      expect(result, isTrue);
    });
  });

  group('compareViaMacOsCmp', () {
    test('throws UnsupportedError when not running on macOS', () async {
      final file1 = createTempFile('cmp_a.txt', 'data');
      final file2 = createTempFile('cmp_b.txt', 'data');

      final nonMacKit = FileKit(
        isMacOSOverride: () => false,
        operatingSystemOverride: () => 'linux',
      );

      expect(
        () => nonMacKit.compareViaMacOsCmp(file1.path, file2.path),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains(
              'compareViaMacOsCmp is only supported on macOS. Current platform:'
              ' linux',
            ),
          ),
        ),
      );
    });

    test(
      'returns true when cmp finds files identical on macOS',
      testOn: 'mac-os',
      () async {
        final file1 = createTempFile('cmp_same_1.txt', 'matching text');
        final file2 = createTempFile('cmp_same_2.txt', 'matching text');

        final result = await fileKit.compareViaMacOsCmp(file1.path, file2.path);

        expect(result, isTrue);
      },
    );

    test(
      'returns false when cmp finds files different on macOS',
      testOn: 'mac-os',
      () async {
        final file1 = createTempFile('cmp_diff_1.txt', 'first file');
        final file2 = createTempFile('cmp_diff_2.txt', 'second file');

        final result = await fileKit.compareViaMacOsCmp(file1.path, file2.path);

        expect(result, isFalse);
      },
    );

    test(
      'returns false when cmp targets a non-existent file on macOS',
      testOn: 'mac-os',
      () async {
        final file1 = createTempFile('exists.txt', 'first file');
        final missingPath = '${tempDir.path}/does_not_exist.txt';

        final result = await fileKit.compareViaMacOsCmp(
          file1.path,
          missingPath,
        );

        expect(result, isFalse);
      },
    );
  });
}
