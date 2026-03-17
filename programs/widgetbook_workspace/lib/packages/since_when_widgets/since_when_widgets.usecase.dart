// lib/packages/since_when_widgets/since_when_widgets.usecase.dart

import 'package:flutter/material.dart';
import 'package:since_when_widgets/since_when_widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

part '_since_when_widgets_hosts.dart';

void _noOp(String _) {}
void _noOpInt(int _) {}

Widget _sectionLabel(BuildContext context, String text) => Align(
  alignment: Alignment.centerLeft,
  child: Text(
    text,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
  ),
);

// ---------------------------------------------------------------------------
// CountedTextField — Default
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Default',
  type: CountedTextField,
  path: 'since_when_widgets/counted_text_field',
)
Widget countedTextFieldDefault(BuildContext context) {
  final maxLength = context.knobs.int.slider(
    label: 'Max Length',
    initialValue: 20,
    min: 1,
    max: 20,
  );
  final borderColor = context.knobs.color(
    label: 'Border Color',
    initialValue: const Color(0xFF9C27B0),
  );
  final errorBorderColor = context.knobs.color(
    label: 'Error Border Color',
    initialValue: const Color(0xFFF44336),
  );
  final caption = context.knobs.string(
    label: 'Caption',
    initialValue: 'First Name',
  );
  final hintText = context.knobs.string(
    label: 'Hint Text',
    initialValue: 'Enter Text',
  );
  final durationMs = context.knobs.int.slider(
    label: 'Message Duration (ms)',
    initialValue: 750,
    min: 250,
    max: 3000,
  );
  final fadeMs = context.knobs.int.slider(
    label: 'Fade Duration (ms)',
    initialValue: 250,
    min: 100,
    max: 1000,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: CountedTextField(
        onChanged: (_) {},
        maxLength: maxLength,
        borderColor: borderColor,
        errorBorderColor: errorBorderColor,
        caption: caption.isEmpty ? null : caption,
        hintText: hintText,
        durationMs: durationMs,
        fadeMs: fadeMs,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// CountedTextField — Live Output
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Live Output',
  type: CountedTextField,
  path: 'since_when_widgets/counted_text_field',
)
Widget countedTextFieldLiveOutput(BuildContext context) {
  final maxLength = context.knobs.int.slider(
    label: 'Max Length',
    initialValue: 10,
    min: 1,
    max: 20,
  );
  final caption = context.knobs.string(
    label: 'Caption',
    initialValue: 'Username',
  );
  final hintText = context.knobs.string(
    label: 'Hint Text',
    initialValue: 'Enter Text',
  );

  return Center(
    child: _LiveOutputHost(
      maxLength: maxLength,
      caption: caption.isEmpty ? null : caption,
      hintText: hintText,
    ),
  );
}

// ---------------------------------------------------------------------------
// CountedTextField — Caption
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Caption',
  type: CountedTextField,
  path: 'since_when_widgets/counted_text_field',
)
Widget countedTextFieldCaption(BuildContext context) =>
    const Center(child: _CaptionShowcase());

// ---------------------------------------------------------------------------
// CountedTextField — Hint Text
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Hint Text',
  type: CountedTextField,
  path: 'since_when_widgets/counted_text_field',
)
Widget countedTextFieldHintText(BuildContext context) =>
    const Center(child: _HintTextShowcase());

// ---------------------------------------------------------------------------
// CountedTextField — Custom Clear Widget
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Custom Clear Widget',
  type: CountedTextField,
  path: 'since_when_widgets/counted_text_field',
)
Widget countedTextFieldCustomClear(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel(context, 'Default — Icons.cancel_outlined'),
          const SizedBox(height: 8),
          CountedTextField(onChanged: (_) {}),
          const SizedBox(height: 32),
          _sectionLabel(context, 'Text'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            clearWidget: Text(
              'Clear',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _sectionLabel(context, 'Emoji'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            clearWidget: Text('🗑️', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 32),
          _sectionLabel(context, 'Filled icon'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            clearWidget: Icon(Icons.cancel, size: 20),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// CountedTextField — Truncation
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Truncation',
  type: CountedTextField,
  path: 'since_when_widgets/counted_text_field',
)
Widget countedTextFieldTruncation(BuildContext context) =>
    const Center(child: _TruncationHost());

// ---------------------------------------------------------------------------
// CountedTextField — RTL
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'RTL',
  type: CountedTextField,
  path: 'since_when_widgets/counted_text_field',
)
Widget countedTextFieldRtl(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel(context, 'RTL — caption + badge on left'),
          const SizedBox(height: 8),
          const CountedTextField(
            onChanged: _noOp,
            caption: 'الاسم الأول',
            hintText: 'أدخل النص',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// TagColorField — Default
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Default',
  type: TagColorField,
  path: 'since_when_widgets/tag_color_field',
)
Widget tagColorFieldDefault(BuildContext context) {
  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 32,
    min: 24,
    max: 80,
  );
  final fadeMs = context.knobs.int.slider(
    label: 'Fade Duration (ms)',
    initialValue: 250,
    min: 100,
    max: 1000,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: TagColorField(
        onChanged: _noOpInt,
        height: height,
        fadeTime: Duration(milliseconds: fadeMs),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// TagColorField — Live Output
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Live Output',
  type: TagColorField,
  path: 'since_when_widgets/tag_color_field',
)
Widget tagColorFieldLiveOutput(BuildContext context) {
  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 32,
    min: 24,
    max: 80,
  );

  return Center(
    child: _TagColorLiveOutputHost(height: height),
  );
}

// ---------------------------------------------------------------------------
// TagColorField — Skip Colors
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Skip Colors',
  type: TagColorField,
  path: 'since_when_widgets/tag_color_field',
)
Widget tagColorFieldSkipColors(BuildContext context) =>
    const Center(child: _TagColorSkipHost());

// ---------------------------------------------------------------------------
// TagColorField — Custom Refresh Widget
// ---------------------------------------------------------------------------

@widgetbook.UseCase(
  name: 'Custom Refresh Widget',
  type: TagColorField,
  path: 'since_when_widgets/tag_color_field',
)
Widget tagColorFieldCustomRefresh(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sectionLabel(context, 'Default — Icons.refresh'),
          const SizedBox(height: 8),
          const TagColorField(onChanged: _noOpInt),
          const SizedBox(height: 32),
          _sectionLabel(context, 'Autorenew icon'),
          const SizedBox(height: 8),
          const TagColorField(
            onChanged: _noOpInt,
            refresh: Icon(Icons.autorenew),
          ),
          const SizedBox(height: 32),
          _sectionLabel(context, 'Text button'),
          const SizedBox(height: 8),
          const TagColorField(
            onChanged: _noOpInt,
            refresh: Text(
              'New',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _sectionLabel(context, 'Emoji'),
          const SizedBox(height: 8),
          const TagColorField(
            onChanged: _noOpInt,
            refresh: Text('🎲', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    ),
  );
}
