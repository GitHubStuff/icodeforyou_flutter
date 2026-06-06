// packages/status_bar_chameleon/lib/src/status_bar_chameleon.dart
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';

final class StatusBarChameleon {
  static const MethodChannel _channel = MethodChannel(
    'status_bar_chameleon/status_bar',
  );

  static bool _isHidden = false;
  static bool get isHidden => _isHidden;

  static Future<void> setStatusBarHidden({
    required bool hidden,
    Duration duration = Duration.zero,
  }) async {
    if (kIsWeb) return; // coverage:ignore-line
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _isHidden = hidden;
    await _channel.invokeMethod<void>('setStatusBarHidden', <String, Object?>{
      'hidden': hidden,
      'durationMs': duration.inMilliseconds,
    });
  }
}
