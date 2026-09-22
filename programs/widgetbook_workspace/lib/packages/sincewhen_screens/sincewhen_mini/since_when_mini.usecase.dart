// programs/widgetbook_workspace/lib/packages/sincewhen_screens/sincewhen_mini/since_when_mini.usecase.dart

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show SinceWhenItem;
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show SinceWhenMini, TimestampDisplay;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const double _demoPadding = 24;
const double _launcherGap = 16;
const double _readoutGap = 8;

/// Fixed instants so the edit-flow payload is deterministic and
/// respects the production invariant `created <= edited <= reviewed`.
final int _createdStamp = DateTime(
  2024,
  7,
  14,
  18,
  27,
  47,
).microsecondsSinceEpoch;

final int _editedStamp = DateTime(
  2024,
  8,
  2,
  9,
  15,
  3,
).microsecondsSinceEpoch;

final int _reviewedStamp = DateTime(
  2024,
  9,
  30,
  21,
  5,
  59,
).microsecondsSinceEpoch;

final int _eventStamp = DateTime(
  2024,
  6,
  1,
  7,
  30,
).microsecondsSinceEpoch;

/// The record the edit flow pushes.
SinceWhenItem _seedItem() => SinceWhenItem(
  id: 42,
  createdTimestamp: _createdStamp,
  reviewedTimestamp: _reviewedStamp,
  editedTimestamp: _editedStamp,
  sequenceNumber: 3,
  content: 'Replaced the kitchen tap washer.',
  eventTimestamp: _eventStamp,
  tldr: 'Kitchen tap washer replaced.',
);

/// Launches the screen in create mode (`item == null`).
///
/// Expected pop behaviors to verify in the readout:
///
/// * Cancel → `null`.
/// * Submit → a record with `id == 0` and all three lifecycle stamps
///   equal — a created record *is* its creation.
@widgetbook.UseCase(
  name: 'Create flow',
  type: SinceWhenMini,
)
Widget buildSinceWhenMiniCreateFlowUseCase(BuildContext context) {
  return const _SinceWhenMiniLauncher(
    key: ValueKey('since_when_mini_create_flow'),
    item: null,
  );
}

/// Launches the screen in edit mode with a seeded record.
///
/// Expected pop behaviors to verify in the readout:
///
/// * Cancel → `null`.
/// * Reviewed (no changes) → only `reviewed` advances.
/// * Update (any change) → `edited == reviewed`, both fresh;
///   `created` never moves.
@widgetbook.UseCase(
  name: 'Edit flow',
  type: SinceWhenMini,
)
Widget buildSinceWhenMiniEditFlowUseCase(BuildContext context) {
  return _SinceWhenMiniLauncher(
    key: const ValueKey('since_when_mini_edit_flow'),
    item: _seedItem(),
  );
}

/// Demo host owning the push/await/pop cycle and the result readout.
///
/// The screen is a route: pushing it through the ambient [Navigator]
/// and rendering what it pops is the contract under review, so the
/// gallery hosts a launcher rather than embedding the screen inline.
///
/// Widgetbook plumbing only.
class _SinceWhenMiniLauncher extends StatefulWidget {
  const _SinceWhenMiniLauncher({
    required this.item,
    super.key,
  });

  final SinceWhenItem? item;

  @override
  State<_SinceWhenMiniLauncher> createState() => _SinceWhenMiniLauncherState();
}

class _SinceWhenMiniLauncherState extends State<_SinceWhenMiniLauncher> {
  bool _hasResult = false;
  SinceWhenItem? _result;

  bool get _isCreate => widget.item == null;

  Future<void> _launch() async {
    final result = await Navigator.push<SinceWhenItem?>(
      context,
      SinceWhenMini.route(item: widget.item),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _hasResult = true;
      _result = result;
    });
    showToast(
      result == null ? 'popped: null (Cancel)' : 'popped: record',
    );
  }

  String get _readout {
    if (!_hasResult) {
      return 'No result yet — launch the screen.';
    }
    final result = _result;
    if (result == null) {
      return 'Popped: null (Cancel)';
    }
    return [
      'Popped record:',
      'id: ${result.id}',
      'created:  ${TimestampDisplay.format(result.createdTimestamp)}',
      'reviewed: ${TimestampDisplay.format(result.reviewedTimestamp)}',
      'edited:   ${TimestampDisplay.format(result.editedTimestamp)}',
      'event:    '
          '${TimestampDisplay.formatOrPlaceholder(result.eventTimestamp)}',
      'sequence: ${result.sequenceNumber}',
      'content:  ${result.content}',
      'tldr:     ${result.tldr}',
      'metaData: ${result.metaData}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return OKToast(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(_demoPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilledButton(
                  onPressed: _launch,
                  child: Text(
                    _isCreate ? 'Launch create screen' : 'Launch edit screen',
                  ),
                ),
                const SizedBox(height: _launcherGap),
                Text('Result', style: textTheme.labelLarge),
                const SizedBox(height: _readoutGap),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _readout,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
