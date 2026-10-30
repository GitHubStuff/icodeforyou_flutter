// plugins/template_ios/example/lib/main.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:template_ios/template_ios.dart';

/// The entry point for the plugin example application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the [TemplateIos] plugin example application.
class MyApp extends StatefulWidget {
  /// Creates an instance of [MyApp].
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// State for [MyApp] that manages platform version fetching and display.
class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _templateIosPlugin = TemplateIos();

  @override
  void initState() {
    super.initState();
    unawaited(initPlatformState());
  }

  /// Initializes and retrieves the host platform version asynchronously.
  ///
  /// Updates [_platformVersion] upon completion. If retrieval encounters a
  /// [PlatformException] or if the returned version string is `null`, an
  /// informative fallback message is assigned instead.
  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion =
          await _templateIosPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // Discard update if the widget unmounted while the asynchronous call 
    // was in flight.
    if (!mounted) {
      return;
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Text('Running on: $_platformVersion\n')),
      ),
    );
  }
}
