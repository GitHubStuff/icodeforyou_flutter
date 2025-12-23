// lib/main.dart
import 'package:edittext_popover/edittext_popover.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleEditorApp());
}

class ExampleEditorApp extends StatelessWidget {
  const ExampleEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EditText Popover Smoke Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SmokeTestScreen(),
    );
  }
}

class SmokeTestScreen extends StatefulWidget {
  const SmokeTestScreen({super.key});

  @override
  State<SmokeTestScreen> createState() => _SmokeTestScreenState();
}

class _SmokeTestScreenState extends State<SmokeTestScreen> {
  final _controller = TextEditingController();
  String _lastResult = 'No result yet';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openEditorManually() async {
    final result = await showEditor(
      context: context,
      initialText: _controller.text,
    );

    switch (result) {
      case EditorCompleted(:final text):
        _controller.text = text;
        setState(() => _lastResult = 'Completed: ${text.length} chars');
      case EditorDismissed(:final text):
        setState(() => _lastResult = 'Dismissed: ${text.length} chars');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smoke Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Using EditorTextField:'),
            const SizedBox(height: 8),
            EditorTextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Tap to edit',
                border: OutlineInputBorder(),
              ),
              onResult: (result) {
                switch (result) {
                  case EditorCompleted(:final text):
                    setState(
                      () => _lastResult = 'Completed: ${text.length} chars',
                    );
                  case EditorDismissed(:final text):
                    setState(
                      () => _lastResult = 'Dismissed: ${text.length} chars',
                    );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Using showEditor directly:'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _openEditorManually,
              child: const Text('Open Editor'),
            ),
            const SizedBox(height: 24),
            Text('Last result: $_lastResult'),
          ],
        ),
      ),
    );
  }
}
