// packages/tool_kit/lib/src/file_walker/file_walker_view.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:tool_kit/src/file_walker/file_walker_cubit.dart'
    show FileWalkerCubit;
import 'package:tool_kit/src/file_walker/file_walker_state.dart'
    show
        FileWalkerProcessing,
        FileWalkerResults,
        FileWalkerState,
        FileWalkerUpdating,
        FileWalkerWaiting;
import 'package:tool_kit/src/macos_select_directory.dart'
    show MacOSSelectDirectory;

/// Screen allowing the user to select a macOS directory, view recursive
/// walk progress, and horizontally scroll the discovered file paths.
class FileWalkerView extends StatelessWidget {
  /// Creates a [FileWalkerView].
  const FileWalkerView({super.key});
  static const double _kFontSize = 22;
  static const double _kVerticalGap = 16;
  static const double _kHorizontalGap = 12;
  static const double _kPadding = 24;
  static const double _kItemHeight = 48;
  static const double _kItemPadding = 8;
  static const int _kSingleLine = 1;

  static const String _kSelectFolderLabel = 'Select Folder';
  static const String _kDialogTitle = 'Choose Folder to Scan';
  static const String _kCancelButtonLabel = 'Cancel';
  static const String _kResetButtonLabel = 'Reset';
  static const String _kSearchingLabel = 'Searching directory...';
  static const String _kFoundLabelPrefix = 'Files discovered: ';
  static const String _kNoFilesLabel = 'No files found in directory.';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileWalkerCubit, FileWalkerState>(
      builder: (BuildContext context, FileWalkerState state) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            trailing: state is FileWalkerResults
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context.read<FileWalkerCubit>().reset(),
                    child: const Text(
                      _kResetButtonLabel,
                      style: TextStyle(fontSize: _kFontSize),
                    ),
                  )
                : null,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(_kPadding),
              child: switch (state) {
                FileWalkerWaiting() => _buildWaiting(context),
                FileWalkerProcessing() => _buildProcessing(context, null),
                FileWalkerUpdating(:final discoveredCount) => _buildProcessing(
                  context,
                  discoveredCount,
                ),
                FileWalkerResults(:final filePaths) => _buildResults(
                  context,
                  filePaths,
                ),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaiting(BuildContext context) {
    return Center(
      child: MacOSSelectDirectory(
        buttonLabel: _kSelectFolderLabel,
        dialogTitle: _kDialogTitle,
        onDirectorySelected: (Directory directory) {
          context.read<FileWalkerCubit>().walk(directory);
        },
      ),
    );
  }

  Widget _buildProcessing(BuildContext context, int? count) {
    final String label = count != null
        ? '$_kFoundLabelPrefix$count'
        : _kSearchingLabel;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupertinoActivityIndicator(radius: _kFontSize),
          const Gap(_kVerticalGap),
          Text(label, style: const TextStyle(fontSize: _kFontSize)),
          const Gap(_kVerticalGap),
          CupertinoButton.filled(
            onPressed: () => context.read<FileWalkerCubit>().cancel(),
            child: const Text(
              _kCancelButtonLabel,
              style: TextStyle(fontSize: _kFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, List<String> filePaths) {
    if (filePaths.isEmpty) {
      return const Center(
        child: Text(
          _kNoFilesLabel,
          style: TextStyle(fontSize: _kFontSize),
        ),
      );
    }

    return ListView.separated(
      itemCount: filePaths.length,
      separatorBuilder: (_, _) => const Gap(_kItemPadding),
      itemBuilder: (BuildContext context, int index) {
        final String path = filePaths[index];
        return SizedBox(
          height: _kItemHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.doc,
                  size: _kFontSize,
                  color: CupertinoColors.secondaryLabel,
                ),
                const Gap(_kHorizontalGap),
                Text(
                  path,
                  maxLines: _kSingleLine,
                  style: const TextStyle(fontSize: _kFontSize),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
