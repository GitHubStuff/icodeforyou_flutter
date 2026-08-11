// packages/crash_framework/lib/src/crash_screen.dart

import 'package:flutter/material.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:go_router/go_router.dart';

/// Padding around the crash report content.
const _kContentPadding = EdgeInsets.all(24);

/// Vertical gap between crash screen sections.
const double _kSectionGap = 12;

/// {@template crash_screen.dart}
/// A terminal error screen the user cannot navigate away from.
///
/// Displays [error] (and optionally [stackTrace]) as selectable text so
/// the user can copy it for a help desk report. System back gestures and
/// buttons are blocked. If [resumePath] is non-null, a resume button is
/// shown that routes there via `context.go`, replacing the broken
/// navigation stack. If [onReport] is non-null, a report button is shown;
/// wire this to a crash-reporting service later without changing this
/// widget.
/// {@endtemplate}
final class CrashScreen extends StatelessWidget {
  /// {@macro crash_screen.dart}
  const CrashScreen({
    required this.error,
    this.stackTrace,
    this.resumePath,
    this.onReport,
    super.key,
  });

  /// The error to display.
  final Object error;

  /// Optional stack trace accompanying [error].
  final StackTrace? stackTrace;

  /// go_router location to resume to; null means no escape is offered.
  final String? resumePath;

  /// Optional callback to report the crash; null hides the report button.
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resume = resumePath;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: _kContentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const Gap(_kSectionGap),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const Gap(_kSectionGap),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      stackTrace == null ? '$error' : '$error\n\n$stackTrace',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                const Gap(_kSectionGap),
                if (onReport != null)
                  OutlinedButton.icon(
                    onPressed: onReport,
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Report'),
                  ),
                if (resume != null) ...[
                  const Gap(_kSectionGap),
                  FilledButton.icon(
                    onPressed: () => context.go(resume),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Resume'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
