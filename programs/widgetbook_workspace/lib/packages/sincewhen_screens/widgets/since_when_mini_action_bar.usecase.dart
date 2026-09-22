// programs/widgetbook_workspace/lib/packages/sincewhen_screens/widgets/since_when_mini_action_bar.usecase.dart
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sincewhen_screens/sincewhen_screens.dart'
    show SinceWhenMiniAction, SinceWhenMiniActionBar;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const double _minDemoWidth = 320;
const double _maxDemoWidth = 1100;
const double _initialDemoWidth = 700;
const double _demoPadding = 24;

/// Interactive use case for [SinceWhenMiniActionBar].
///
/// The full behavior matrix is reachable from the knob panel:
///
/// * a dropdown selects the contextual [SinceWhenMiniAction]
///   (`Submit` / `Update` / `Reviewed`),
/// * a boolean toggles primary enablement (the disabled rendering is
///   the case galleries usually forget),
/// * a width slider simulates the screen-width constraint.
///
/// Callback traffic is reported via toasts.
@widgetbook.UseCase(
  name: 'Interactive',
  type: SinceWhenMiniActionBar,
)
Widget buildSinceWhenMiniActionBarUseCase(BuildContext context) {
  final primaryAction = context.knobs.object.dropdown<SinceWhenMiniAction>(
    label: 'Primary action',
    options: SinceWhenMiniAction.values,
    initialOption: SinceWhenMiniAction.submit,
    labelBuilder: (action) => '${action.name} — "${action.label}"',
  );
  final isPrimaryEnabled = context.knobs.boolean(
    label: 'Primary enabled',
    initialValue: true,
  );
  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: _initialDemoWidth,
    min: _minDemoWidth,
    max: _maxDemoWidth,
  );
  return OKToast(
    child: Center(
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(_demoPadding),
          child: SinceWhenMiniActionBar(
            primaryAction: primaryAction,
            isPrimaryEnabled: isPrimaryEnabled,
            onPrimaryPressed: () =>
                showToast('onPrimaryPressed: ${primaryAction.label}'),
            onCancelPressed: () => showToast('onCancelPressed'),
          ),
        ),
      ),
    ),
  );
}
