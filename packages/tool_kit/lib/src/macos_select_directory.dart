// packages/tool_kit/lib/src/macos_select_directory.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

/// Signature for folder-picking operations in testing and production.
typedef DirectoryPickerFn =
    Future<String?> Function({String? dialogTitle, String? initialDirectory});

/// A widget tailored for macOS that prompts the user to select a folder
/// from their system and returns a [Directory] instance in a callback.
class MacOSSelectDirectory extends StatefulWidget {
  /// Creates a macOS folder selection widget.
  const MacOSSelectDirectory({
    required this.onDirectorySelected,
    required this.buttonLabel,
    required this.dialogTitle,
    super.key,
    this.initialDirectory,
    this.onCancel,
    @visibleForTesting this.isMacOSOverride,
    @visibleForTesting this.operatingSystemOverride,
    @visibleForTesting this.pickerOverride,
  });

  /// Callback triggered when a folder is successfully selected.
  ///
  /// Passes the [Directory] instance of the selected folder.
  final ValueChanged<Directory> onDirectorySelected;

  /// Optional callback triggered when the user cancels folder selection.
  final VoidCallback? onCancel;

  /// Label displayed on the select button.
  final String buttonLabel;

  /// Title shown at the top of the native folder picker sheet.
  final String dialogTitle;

  /// Optional initial folder path to open the dialog in.
  final String? initialDirectory;

  /// Test hook to simulate macOS environment.
  final bool Function()? isMacOSOverride;

  /// Test hook to simulate OS name.
  final String Function()? operatingSystemOverride;

  /// Test hook to mock [FilePicker.getDirectoryPath].
  final DirectoryPickerFn? pickerOverride;

  @override
  State<MacOSSelectDirectory> createState() => _MacOSSelectDirectoryState();
}

class _MacOSSelectDirectoryState extends State<MacOSSelectDirectory> {
  static const double _kMinFontSize = 22;
  static const double _kIconSize = 24;
  static const double _kHorizontalGap = 8;
  static const double _kVerticalGap = 8;
  static const int _kMaxPathLines = 1;

  String? _selectedPath;
  bool _isLoading = false;

  Future<void> _pickDirectory() async {
    final bool isMacOS = widget.isMacOSOverride != null
        ? widget.isMacOSOverride!()
        : Platform.isMacOS;

    if (!isMacOS) {
      final String os = widget.operatingSystemOverride != null
          ? widget.operatingSystemOverride!()
          : Platform.operatingSystem;
      throw UnsupportedError(
        'MacOSSelectDirectory is only supported on macOS, not platform: $os',
      );
    }

    setState(() => _isLoading = true);

    try {
      final picker = widget.pickerOverride ?? FilePicker.getDirectoryPath;
      final String? selectedPath = await picker(
        dialogTitle: widget.dialogTitle,
        initialDirectory: widget.initialDirectory,
      );

      if (selectedPath != null) {
        setState(() => _selectedPath = selectedPath);
        widget.onDirectorySelected(Directory(selectedPath));
      } else {
        widget.onCancel?.call();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton.filled(
          onPressed: _isLoading ? null : _pickDirectory,
          child: _isLoading
              ? const CupertinoActivityIndicator(
                  color: CupertinoColors.white,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.folder, size: _kIconSize),
                    const Gap(_kHorizontalGap),
                    Text(
                      widget.buttonLabel,
                      style: const TextStyle(fontSize: _kMinFontSize),
                    ),
                  ],
                ),
        ),
        if (_selectedPath != null) ...[
          const Gap(_kVerticalGap),
          Text(
            _selectedPath!,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: _kMinFontSize,
              color: CupertinoColors.secondaryLabel,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: _kMaxPathLines,
          ),
        ],
      ],
    );
  }
}
