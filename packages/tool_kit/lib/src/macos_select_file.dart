// packages/tool_kit/lib/src/macos_select_file.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:gap/gap.dart';

/// Signature for file-picking operations in testing and production.
typedef FilePickerFn =
    Future<PlatformFile?> Function({
      String? dialogTitle,
      FileType type,
      List<String>? allowedExtensions,
    });

/// A widget tailored for macOS that prompts the user to select a file
/// from their system and returns its absolute file system path.
class MacOSSelectFile extends StatefulWidget {
  /// Creates a macOS file selection widget.
  const MacOSSelectFile({
    required this.onFileSelected,
    required this.buttonLabel,
    required this.dialogTitle,
    super.key,
    this.onCancel,
    this.allowedExtensions,
    this.includeHidden = false,
    @visibleForTesting this.isMacOSOverride,
    @visibleForTesting this.operatingSystemOverride,
    @visibleForTesting this.pickerOverride,
  });

  /// Callback triggered when a file is successfully selected.
  ///
  /// Passes the absolute system path string of the selected file.
  final ValueChanged<String> onFileSelected;

  /// Optional callback triggered when the user cancels the file selection.
  final VoidCallback? onCancel;

  /// Label displayed on the select button.
  final String buttonLabel;

  /// Title shown at the top of the native file picker sheet.
  final String dialogTitle;

  /// Optional allowed file extensions (for example, `['txt', 'pdf']`).
  /// Defaults to `null`, which allows any file type.
  final List<String>? allowedExtensions;

  /// Whether to include files starting with `.`. Defaults to `false`.
  final bool includeHidden;

  /// Test hook to simulate macOS environment.
  final bool Function()? isMacOSOverride;

  /// Test hook to simulate OS name.
  final String Function()? operatingSystemOverride;

  /// Test hook to mock [FilePicker.pickFile].
  final FilePickerFn? pickerOverride;

  @override
  State<MacOSSelectFile> createState() => _MacOSSelectFileState();
}

class _MacOSSelectFileState extends State<MacOSSelectFile> {
  static const double _kMinFontSize = 22;
  static const double _kIconSize = 24;
  static const double _kHorizontalGap = 8;
  static const double _kVerticalGap = 8;
  static const int _kMaxPathLines = 1;
  static const String _kHiddenFilePrefix = '.';

  String? _selectedPath;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    final bool isMacOS = widget.isMacOSOverride != null
        ? widget.isMacOSOverride!()
        : Platform.isMacOS;

    if (!isMacOS) {
      final String os = widget.operatingSystemOverride != null
          ? widget.operatingSystemOverride!()
          : Platform.operatingSystem;
      throw UnsupportedError(
        'MacOSSelectFile is only supported on macOS. Current platform: $os',
      );
    }

    setState(() => _isLoading = true);

    try {
      final picker = widget.pickerOverride ?? FilePicker.pickFile;
      final PlatformFile? file = await picker(
        dialogTitle: widget.dialogTitle,
        type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: widget.allowedExtensions,
      );

      if (file != null) {
        final String? path = file.path;
        final bool isHidden = file.name.startsWith(_kHiddenFilePrefix);

        if (path != null && (widget.includeHidden || !isHidden)) {
          setState(() => _selectedPath = path);
          widget.onFileSelected(path);
        }
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
          onPressed: _isLoading ? null : _pickFile,
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
