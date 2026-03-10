// lib/packages/adaptive_modal/adaptive_modal.usecase.dart
// ---------------------------------------------------------------------------
// adaptive_modal.usecase.dart — widgetbook use cases for adaptive_modal.
//
// AdaptiveModalController<T> is generic so it cannot be used directly as a
// widgetbook type token. AdaptiveModal is a plain marker class used solely
// for grouping use cases in the widgetbook component tree.
// ---------------------------------------------------------------------------

import 'package:adaptive_modal/adaptive_modal.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

part '_demo_widgets.dart';

// ---------------------------------------------------------------------------
// Marker class — widgetbook type token only
// ---------------------------------------------------------------------------

/// Non-generic marker class used as the widgetbook [widgetbook.UseCase] type
/// token.
///
/// widgetbook_generator requires a plain non-generic [Type] reference.
/// [AdaptiveModalController] is generic so this class stands in for it
/// purely for component-tree grouping purposes.
class AdaptiveModal {}

// ---------------------------------------------------------------------------
// Use Cases
// ---------------------------------------------------------------------------

/// Default modal — barrier dismissible, default (X) close icon.
/// Tap the trigger button to open. Tap barrier or X to dismiss.
@widgetbook.UseCase(name: 'Default', type: AdaptiveModal)
Widget adaptiveModalDefault(BuildContext context) {
  return const _DefaultModalDemo();
}

/// Custom close icon — replaces the default X with a back arrow.
@widgetbook.UseCase(name: 'Custom Close Icon', type: AdaptiveModal)
Widget adaptiveModalCustomIcon(BuildContext context) {
  return const _CustomIconModalDemo();
}

/// No barrier — background widgets remain fully interactive while modal is
/// open.
/// Tap the counter button behind the modal to prove it still works.
@widgetbook.UseCase(name: 'No Barrier', type: AdaptiveModal)
Widget adaptiveModalNoBarrier(BuildContext context) {
  return const _NoBarrierModalDemo();
}

/// Return value — modal resolves with the selected item via 
/// controller.resolve().
/// The returned value is displayed beneath the trigger button.
@widgetbook.UseCase(name: 'Return Value', type: AdaptiveModal)
Widget adaptiveModalReturnValue(BuildContext context) {
  return const _ReturnValueModalDemo();
}
