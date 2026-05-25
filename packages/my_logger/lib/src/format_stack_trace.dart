// package/lib/src/utils/format_stack_trace.dart
// ignore_for_file: comment_references, public_member_api_docs
import 'package:stack_trace/stack_trace.dart';

import 'trace_color.dart';

/// Predicate used to decide whether a [Frame] should be folded out of the
/// formatted trace. Return `true` to fold (hide) the frame.
typedef FrameFilter = bool Function(Frame frame);

/// Default fold: hides Dart SDK (`dart:*`) and Flutter framework frames.
/// Reused as the default value for [formatStackTrace]'s `foldWhen` parameter.
bool defaultFrameworkFold(Frame f) => f.isCore || f.package == 'flutter';

/// Captures the current stack trace, formats it as a readable string, and
/// optionally wraps it in an ANSI color.
///
/// Returns the formatted trace — the caller decides where it goes
/// (`print`, file, backend, logger, etc.).
///
/// - [label] identifies this trace in the output header.
/// - [depth] caps how many frames are shown; `null` shows all.
/// - [foldWhen] hides matching frames before formatting; `null` disables
///   folding entirely. Defaults to [defaultFrameworkFold] which hides
///   `dart:*` and `package:flutter` frames.
/// - [traceColor] wraps the entire output in an ANSI color when stdout
///   supports it; `null` means no color.
/// - [now] overrides the timestamp source (testing seam).
/// - [supportsAnsi] overrides the TTY check forwarded to [TraceColor.apply]
///   (testing seam, also useful when redirecting to a file).
String formatStackTrace(
  String label, {
  int? depth = 5,
  FrameFilter? foldWhen = defaultFrameworkFold,
  TraceColor? traceColor,
  DateTime Function()? now,
  bool Function()? supportsAnsi,
}) {
  final timestamp = (now ?? DateTime.now).call().toUtc().toIso8601String();

  var trace = Trace.current(1); // skip formatStackTrace's own frame
  if (foldWhen != null) {
    trace = trace.foldFrames(foldWhen, terse: true);
  }
  final frames =
      depth == null ? trace.frames : trace.frames.take(depth).toList();

  final header = '── $timestamp · $label ──';
  final buffer = StringBuffer()..writeln(header);
  for (var i = 0; i < frames.length; i++) {
    final f = frames[i];
    buffer.writeln('  #$i  ${f.member}  (${f.uri}:${f.line})');
  }
  buffer.write('─' * header.length);

  final output = buffer.toString();
  return traceColor?.apply(output, supportsAnsi: supportsAnsi) ?? output;
}
