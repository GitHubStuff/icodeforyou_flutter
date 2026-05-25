// lib/src/pages/profile_page.dart

import 'package:animated_widgets/animated_widgets.dart'
    show FaderCubit, FaderWidget;
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';

final FaderCubit _faderCubit = FaderCubit();

class FaderPage extends StatefulWidget {
  const FaderPage({super.key});

  @override
  State<FaderPage> createState() => _FaderPageState();
}

class _FaderPageState extends State<FaderPage> {
  static const List<String> _strings = <String>[
    'Dogs Rock',
    'Cats complain',
    'Cuddles Matter',
    'Evict Trump',
    'I Rock',
  ];

  int _index = 0;

  void _next() {
    // Push the next string to the cubit; it fades in now or queues if a fade
    // is still in flight. Wrap the index so it cycles through the five.
    _faderCubit.push(_strings[_index]);
    _index = (_index + 1) % _strings.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fader Demo'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaderWidget(
            cubit: _faderCubit,
          ).withPaddingAll(8).withBorder(color: Colors.blueGrey),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _next,
        child: const Icon(Icons.skip_next),
      ),
    );
  }
}
