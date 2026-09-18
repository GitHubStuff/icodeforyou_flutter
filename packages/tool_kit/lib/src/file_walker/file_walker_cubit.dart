// packages/tool_kit/lib/src/file_walker_cubit.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:tool_kit/src/file_walker/file_walker_state.dart';

/// A Cubit that recursively searches a directory for file paths.
class FileWalkerCubit extends Cubit<FileWalkerState> {
  /// Creates a [FileWalkerCubit] starting in the waiting state.
  FileWalkerCubit() : super(const FileWalkerWaiting());
  static const String _kHiddenPrefix = '.';
  static const int _kProgressThrottle = 50;

  StreamSubscription<FileSystemEntity>? _sub;
  bool _isCanceled = false;

  /// Recursively walks [rootDirectory] collecting all file paths.
  ///
  /// Ignores entities with names starting with `.` by default.
  void walk(Directory rootDirectory, {bool includeHidden = false}) {
    _cancelActiveWalk();
    _isCanceled = false;
    emit(const FileWalkerProcessing());

    final List<String> paths = [];
    int batchCounter = 0;

    _sub = rootDirectory
        .list(recursive: true, followLinks: false)
        .listen(
          (FileSystemEntity entity) {
            if (_isCanceled) return;

            final String baseName = p.basename(entity.path);
            if (!includeHidden && baseName.startsWith(_kHiddenPrefix)) {
              return;
            }

            if (entity is File) {
              paths.add(entity.path);
              batchCounter++;

              if (batchCounter >= _kProgressThrottle) {
                batchCounter = 0;
                emit(FileWalkerUpdating(discoveredCount: paths.length));
              }
            }
          },
          onDone: () {
            if (!_isCanceled) {
              emit(FileWalkerResults(filePaths: List.unmodifiable(paths)));
            }
          },
          onError: (Object _) {
            if (!_isCanceled) {
              emit(FileWalkerResults(filePaths: List.unmodifiable(paths)));
            }
          },
          cancelOnError: false,
        );
  }

  /// Cancels an in-progress walk and resets to [FileWalkerWaiting].
  void cancel() {
    _cancelActiveWalk();
    emit(const FileWalkerWaiting());
  }

  /// Resets the cubit back to the initial [FileWalkerWaiting] state.
  void reset() {
    _cancelActiveWalk();
    emit(const FileWalkerWaiting());
  }

  void _cancelActiveWalk() {
    _isCanceled = true;
    unawaited(_sub?.cancel());
    _sub = null;
  }

  @override
  Future<void> close() {
    _cancelActiveWalk();
    return super.close();
  }
}
