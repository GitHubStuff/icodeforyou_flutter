// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';

final class StatusBarChameleon {
  static const MethodChannel _channel = MethodChannel(
    'status_bar_chameleon/status_bar',
  );

  static Future<void> setStatusBarHidden({required bool hidden}) async {
    if (kIsWeb) return; // coverage:ignore-line
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    await _channel.invokeMethod<void>('setStatusBarHidden', <String, Object?>{
      'hidden': hidden,
    });
  }
}
