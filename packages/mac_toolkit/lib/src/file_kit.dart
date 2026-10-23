// packages/tool_kit/lib/src/file_kit.dart
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// A utility class providing file comparison helpers for local files.
class FileKit {
  /// Creates a [FileKit] instance with optional platform overrides for
  /// unit testing.
  FileKit({
    bool Function()? isMacOSOverride,
    String Function()? operatingSystemOverride,
  }) : isMacOSOverride = isMacOSOverride ?? (() => Platform.isMacOS),
       operatingSystemOverride =
           operatingSystemOverride ?? (() => Platform.operatingSystem);

  /// Internal hook for testing non-macOS platforms.
  @visibleForTesting
  final bool Function() isMacOSOverride;

  /// Internal hook for testing operating system string reporting.
  @visibleForTesting
  final String Function() operatingSystemOverride;

  /// Compares two [File] instances for content equality by comparing their
  /// sizes and cryptographic hashes.
  ///
  /// The comparison performs three sequential checks:
  /// 1. Verifies that both [file1] and [file2] exist on disk.
  /// 2. Compares file byte lengths; files of differing sizes return `false`
  ///    immediately without reading contents.
  /// 3. Streams both files through the [sha256] hashing algorithm to confirm
  ///    content equivalence without buffering large files entirely in memory.
  ///
  /// Returns `true` if both files exist and share identical byte contents;
  /// otherwise returns `false`.
  ///
  /// Throws a [FileSystemException] if read permissions are denied.
  Future<bool> areFilesIdentical(File file1, File file2) async {
    // 1. Quick existence check
    // ignore: avoid_slow_async_io
    if (!await file1.exists() || !await file2.exists()) return false;

    // 2. Fast check: Different byte sizes mean they cannot be identical
    final len1 = await file1.length();
    final len2 = await file2.length();
    if (len1 != len2) return false;

    // 3. Stream bytes through SHA-256 (handles multi-GB files without
    // high RAM usage)
    final hash1 = await sha256.bind(file1.openRead()).first;
    final hash2 = await sha256.bind(file2.openRead()).first;

    return hash1 == hash2;
  }

  /// Compares two files byte-by-byte using the native macOS `cmp` command.
  ///
  /// Executes `cmp -s [path1] [path2]`, which silently terminates at the
  /// first differing byte.
  ///
  /// Returns `true` if the files are byte-for-byte identical (exit code `0`),
  /// or `false` if differences are detected, files are missing, or a non-zero
  /// exit code is returned.
  ///
  /// Throws an [UnsupportedError] if called on an operating system other
  /// than macOS.
  /// Throws a [ProcessException] if `cmp` fails to execute.
  Future<bool> compareViaMacOsCmp(String path1, String path2) async {
    if (!isMacOSOverride()) {
      throw UnsupportedError(
        'compareViaMacOsCmp is only supported on macOS. Current platform:'
        ' ${operatingSystemOverride()}',
      );
    }

    // 'cmp -s' returns exit code 0 if identical, 1 if different
    final result = await Process.run('cmp', ['-s', path1, path2]);
    return result.exitCode == 0;
  }
}
