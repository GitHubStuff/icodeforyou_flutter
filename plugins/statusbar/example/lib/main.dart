// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:statusbar/statusbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DemoScreen());
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  bool _hidden = false;

  Future<void> _toggle() async {
    _hidden = !_hidden;
    await StatusBar.setStatusBarHidden(hidden: _hidden);
    setState(() {});
  }

  @override
  void dispose() {
    // always restore
    unawaited(StatusBar.setStatusBarHidden(hidden: false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('statusbar example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggle,
          child: Text(_hidden ? 'Show Status Bar' : 'Hide Status Bar'),
        ),
      ),
    );
  }
}
