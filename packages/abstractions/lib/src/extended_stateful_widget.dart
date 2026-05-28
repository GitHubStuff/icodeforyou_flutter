// abstractiions/lib/src/extended_stateful_widget.dart

// ignore_for_file: document_ignores, public_member_api_docs

import 'package:flutter/material.dart';

/// Adds helpers:
///  afterFirstLayout
///  didChangeAppLifecycleState
///  didChangeMetrics
///  didChangePlatformBrightness
///  didChangeTextScaleFactor

abstract class ExtendedStatefulWidget<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  @mustCallSuper
  @override
  void initState() {
    super.initState();
    final instance = WidgetsBinding.instance;
    reportTextScaleFactor(instance.platformDispatcher.textScaleFactor);
    instance
      ..addPostFrameCallback((_) => afterFirstLayout(context))
      ..addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @mustCallSuper
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Add a post-frame callback to ensure MediaQuery has updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Now it's safe to read the updated MediaQuery
      //eg: context.read<MediaQueryCubit>().refresh(context);
    });
  }

  @override
  void didChangePlatformBrightness() {}

  @mustCallSuper
  @override
  void didChangeTextScaleFactor() {
    final textScalceFactor =
        WidgetsBinding.instance.platformDispatcher.textScaleFactor;
    reportTextScaleFactor(textScalceFactor);
  }

  @mustCallSuper
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void afterFirstLayout(BuildContext context) {}

  /// Called when the text scale factor changes.
  void reportTextScaleFactor(double? textScaleFactor) {}
}
