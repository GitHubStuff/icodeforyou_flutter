// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:settings_widget/src/app_settings_entry.dart';

class _StubEntry extends AppSettingsEntry {
  const _StubEntry({required this.label});
  final String label;

  @override
  Widget get title => Text(label);

  @override
  Widget build(BuildContext context) => Text(label);
}

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: child),
);

void main() {}
