// programs/widgetbook_workspace/lib/packages/ext_duration/scanners.usecase.dart
import 'package:ext_duration/ext_duration.dart'
    show tokenPatterns, valuePatterns;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const String _initialPattern = 'start |%02h||:%3n|| total=%d| reported';

@widgetbook.UseCase(name: 'Live Parse', type: TokenScannerPlayground)
Widget buildTokenScannerPlaygroundUseCase(BuildContext context) =>
    const TokenScannerPlayground();

/// Live harness for [tokenPatterns] and [valuePatterns].
///
/// Type a pattern, tap Parse, and read the results of each scanner in its
/// own pane. A [FormatException] is rendered via `toString()` in the pane
/// of the scanner that threw it.
class TokenScannerPlayground extends StatefulWidget {
  const TokenScannerPlayground({super.key});

  @override
  State<TokenScannerPlayground> createState() => _TokenScannerPlaygroundState();
}

class _TokenScannerPlaygroundState extends State<TokenScannerPlayground> {
  final TextEditingController _controller = TextEditingController(
    text: _initialPattern,
  );

  String _tokensOutput = '';
  String _valuesOutput = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parse() {
    final String pattern = _controller.text;
    setState(() {
      _tokensOutput = _render(() => tokenPatterns(pattern));
      _valuesOutput = _render(() => valuePatterns(pattern));
    });
  }

  String _render(List<String> Function() scan) {
    try {
      return scan().map((String item) => "'$item'").join('\n');
    } on FormatException catch (error) {
      return error.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Pattern',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(fontFamily: 'monospace'),
            onSubmitted: (_) => _parse(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _parse,
            child: const Text('Parse'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: _OutputPane(
                    title: 'tokenPatterns()',
                    text: _tokensOutput,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutputPane(
                    title: 'valuePatterns()',
                    text: _valuesOutput,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutputPane extends StatelessWidget {
  const _OutputPane({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
