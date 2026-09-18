// packages/tool_kit/lib/src/file_walker/file_walker_state.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

/// Base class representing the state of the directory walk.
@immutable
sealed class FileWalkerState {
  const FileWalkerState();
}

/// Waiting for the user to pick a root directory.
final class FileWalkerWaiting extends FileWalkerState {
  const FileWalkerWaiting();
}

/// Directory walk has initiated.
final class FileWalkerProcessing extends FileWalkerState {
  const FileWalkerProcessing();
}

/// Intermediate update emitted as files are encountered.
final class FileWalkerUpdating extends FileWalkerState {
  const FileWalkerUpdating({required this.discoveredCount});

  /// The count of files found so far.
  final int discoveredCount;
}

/// The recursive walk has finished with the collected file paths.
final class FileWalkerResults extends FileWalkerState {
  const FileWalkerResults({required this.filePaths});

  /// The collection of discovered absolute file paths.
  final List<String> filePaths;
}
