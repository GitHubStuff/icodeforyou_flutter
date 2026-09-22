// programs/widgetbook_workspace/lib/packages/sincewhen_screens/widgets/since_when_mini_text_column.usecase.dart

import 'package:flutter/material.dart';
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show SinceWhenMiniTextColumn;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const double _minDemoWidth = 320;
const double _maxDemoWidth = 900;
const double _initialDemoWidth = 640;
const double _minDemoHeight = 200;
const double _maxDemoHeight = 700;
const double _initialDemoHeight = 640;
const double _demoPadding = 24;
const double _statusGap = 12;

const String _seedContent =
    'Replaced the kitchen tap washer.\n'
    'Old one had perished; kept the spare in the garage tin.';
const String _seedTldr = 'Kitchen tap washer replaced.';
const String _seedMetaData = 'location: kitchen\npart: 12mm washer';

/// Interactive use case starting with all fields empty.
///
/// The create-mode presentation: every hint visible, content focused.
@widgetbook.UseCase(
  name: 'Empty',
  type: SinceWhenMiniTextColumn,
)
Widget buildSinceWhenMiniTextColumnEmptyUseCase(BuildContext context) {
  return _TextColumnDemo(
    key: const ValueKey('since_when_mini_text_column_empty'),
    initialContent: '',
    initialTldr: '',
    initialMetaData: '',
    width: _widthKnob(context),
    height: _heightKnob(context),
  );
}

/// Interactive use case starting with seeded text in every field.
///
/// The edit-mode presentation; shrink the height knob to watch the
/// column honor its own-scrolling contract.
@widgetbook.UseCase(
  name: 'Pre-filled',
  type: SinceWhenMiniTextColumn,
)
Widget buildSinceWhenMiniTextColumnPreFilledUseCase(
  BuildContext context,
) {
  return _TextColumnDemo(
    key: const ValueKey('since_when_mini_text_column_pre_filled'),
    initialContent: _seedContent,
    initialTldr: _seedTldr,
    initialMetaData: _seedMetaData,
    width: _widthKnob(context),
    height: _heightKnob(context),
  );
}

/// Width knob simulating the text-column constraint of the iPad-mini
/// landscape layout.
double _widthKnob(BuildContext context) {
  return context.knobs.double.slider(
    label: 'Width',
    initialValue: _initialDemoWidth,
    min: _minDemoWidth,
    max: _maxDemoWidth,
  );
}

/// Height knob: shrink it to exercise the column's internal
/// scrolling, the behavior a fixed-size gallery would never show.
double _heightKnob(BuildContext context) {
  return context.knobs.double.slider(
    label: 'Height',
    initialValue: _initialDemoHeight,
    min: _minDemoHeight,
    max: _maxDemoHeight,
  );
}

/// Stateful demo host: owns the controllers and focus node (lifecycle
/// objects the builder function cannot own) and renders a live
/// callback readout.
///
/// Keystroke callbacks report inline rather than via toast: a toast
/// per keystroke is spam that buries the widget under review.
///
/// Widgetbook plumbing only — product state for this widget lives in
/// `SinceWhenMiniCubit`, not here.
class _TextColumnDemo extends StatefulWidget {
  const _TextColumnDemo({
    required this.initialContent,
    required this.initialTldr,
    required this.initialMetaData,
    required this.width,
    required this.height,
    super.key,
  });

  final String initialContent;
  final String initialTldr;
  final String initialMetaData;
  final double width;
  final double height;

  @override
  State<_TextColumnDemo> createState() => _TextColumnDemoState();
}

class _TextColumnDemoState extends State<_TextColumnDemo> {
  late final TextEditingController _contentController = TextEditingController(
    text: widget.initialContent,
  );
  late final TextEditingController _tldrController = TextEditingController(
    text: widget.initialTldr,
  );
  late final TextEditingController _metaDataController = TextEditingController(
    text: widget.initialMetaData,
  );
  final FocusNode _contentFocusNode = FocusNode(
    debugLabel: 'text_column_demo_content',
  );

  String _lastChanged = 'none yet';

  @override
  void dispose() {
    _contentController.dispose();
    _tldrController.dispose();
    _metaDataController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _reportChange(String field, String value) {
    setState(() {
      _lastChanged = '$field (${value.length} chars)';
    });
  }

  String get _statusLine =>
      'last onChanged: $_lastChanged | '
      'content ${_contentController.text.length} / '
      'tldr ${_tldrController.text.length} / '
      'metaData ${_metaDataController.text.length}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_demoPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: SinceWhenMiniTextColumn(
                contentController: _contentController,
                tldrController: _tldrController,
                metaDataController: _metaDataController,
                contentFocusNode: _contentFocusNode,
                onContentChanged: (value) => _reportChange('content', value),
                onTldrChanged: (value) => _reportChange('tldr', value),
                onMetaDataChanged: (value) => _reportChange('metaData', value),
              ),
            ),
            const SizedBox(height: _statusGap),
            SizedBox(
              width: widget.width,
              child: Text(
                _statusLine,
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
