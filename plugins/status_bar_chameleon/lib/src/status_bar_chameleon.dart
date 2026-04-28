// ignore_for_file: public_member_api_docs

import 'dart:io' show Platform;

import 'package:flutter/services.dart';

final class StatusBarChameleon {
  const StatusBarChameleon._();

  static const MethodChannel _channel = MethodChannel(
    'status_bar_chameleon/status_bar',
  );

  static Future<void> setStatusBarHidden({required bool hidden}) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;

    await _channel.invokeMethod<void>('setStatusBarHidden', <String, Object?>{
      'hidden': hidden,
    });
  }
}
