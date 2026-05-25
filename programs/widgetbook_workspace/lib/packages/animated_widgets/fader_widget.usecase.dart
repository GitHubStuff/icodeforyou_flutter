// lib/packages/animated_widgets/fader_widget.usecase.dart

import 'dart:async';

import 'package:animated_widgets/animated_widgets.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class _FaderHost extends StatefulWidget {
  const _FaderHost({
    required this.duration,
  });

  final Duration duration;

  @override
  State<_FaderHost> createState() => _FaderHostState();
}

class _FaderHostState extends State<_FaderHost> {
  static const List<String> _strings = <String>[
    'Dogs Rock',
    'I got this',
    'Cuddles Matter',
    'Clean Style coder',
    'I Rock, I use SOLID, Clean Code, and Best Practices',
  ];

  // Held across rebuilds so changing the curve never resets the fade queue.
  final FaderCubit _cubit = FaderCubit();

  int _stringIndex = 0;
  Curve _curve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _cubit.push(_strings[_stringIndex]);
  }

  void _advanceString() {
    _stringIndex = (_stringIndex + 1) % _strings.length;
    _cubit.push(_strings[_stringIndex]);
  }

  void _selectCurveAndAdvance(Curve curve) {
    setState(() => _curve = curve);
    _advanceString();
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 240,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
              ),
              child: Center(
                child: FaderWidget(
                  cubit: _cubit,
                  duration: widget.duration,
                  curve: _curve,
                ).withPaddingAll(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _advanceString,
          child: const Text('Next string'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _curves.length,
            itemBuilder: (context, index) {
              final entry = _curves[index];
              final selected = entry.curve == _curve;
              return ListTile(
                dense: true,
                selected: selected,
                trailing: selected ? const Icon(Icons.check) : null,
                title: Text(entry.name),
                onTap: () => _selectCurveAndAdvance(entry.curve),
              );
            },
          ),
        ),
      ],
    );
  }
}

const List<({String name, Curve curve})> _curves =
    <
      ({
        String name,
        Curve curve,
      })
    >[
      (name: 'linear', curve: Curves.linear),
      (name: 'decelerate', curve: Curves.decelerate),
      (name: 'ease', curve: Curves.ease),
      (name: 'easeIn', curve: Curves.easeIn),
      (name: 'easeOut', curve: Curves.easeOut),
      (name: 'easeInOut', curve: Curves.easeInOut),
      (name: 'easeInSine', curve: Curves.easeInSine),
      (name: 'easeOutSine', curve: Curves.easeOutSine),
      (name: 'easeInOutSine', curve: Curves.easeInOutSine),
      (name: 'easeInQuad', curve: Curves.easeInQuad),
      (name: 'easeOutQuad', curve: Curves.easeOutQuad),
      (name: 'easeInOutQuad', curve: Curves.easeInOutQuad),
      (name: 'easeInCubic', curve: Curves.easeInCubic),
      (name: 'easeOutCubic', curve: Curves.easeOutCubic),
      (name: 'easeInOutCubic', curve: Curves.easeInOutCubic),
      (name: 'easeInQuart', curve: Curves.easeInQuart),
      (name: 'easeOutQuart', curve: Curves.easeOutQuart),
      (name: 'easeInOutQuart', curve: Curves.easeInOutQuart),
      (name: 'easeInQuint', curve: Curves.easeInQuint),
      (name: 'easeOutQuint', curve: Curves.easeOutQuint),
      (name: 'easeInOutQuint', curve: Curves.easeInOutQuint),
      (name: 'easeInExpo', curve: Curves.easeInExpo),
      (name: 'easeOutExpo', curve: Curves.easeOutExpo),
      (name: 'easeInOutExpo', curve: Curves.easeInOutExpo),
      (name: 'easeInCirc', curve: Curves.easeInCirc),
      (name: 'easeOutCirc', curve: Curves.easeOutCirc),
      (name: 'easeInOutCirc', curve: Curves.easeInOutCirc),
      (name: 'easeInBack', curve: Curves.easeInBack),
      (name: 'easeOutBack', curve: Curves.easeOutBack),
      (name: 'easeInOutBack', curve: Curves.easeInOutBack),
      (name: 'bounceIn', curve: Curves.bounceIn),
      (name: 'bounceOut', curve: Curves.bounceOut),
      (name: 'bounceInOut', curve: Curves.bounceInOut),
      (name: 'elasticIn', curve: Curves.elasticIn),
      (name: 'elasticOut', curve: Curves.elasticOut),
      (name: 'elasticInOut', curve: Curves.elasticInOut),
      (name: 'fastOutSlowIn', curve: Curves.fastOutSlowIn),
      (name: 'slowMiddle', curve: Curves.slowMiddle),
      (name: 'fastLinearToSlowEaseIn', curve: Curves.fastLinearToSlowEaseIn),
      (name: 'fastEaseInToSlowEaseOut', curve: Curves.fastEaseInToSlowEaseOut),
      (name: 'easeInToLinear', curve: Curves.easeInToLinear),
      (name: 'linearToEaseOut', curve: Curves.linearToEaseOut),
    ];

@widgetbook.UseCase(name: 'Curve explorer', type: FaderWidget)
Widget faderWidgetCurveExplorer(BuildContext context) {
  final ms = context.knobs.double.slider(
    label: 'Duration (ms)',
    initialValue: 1500,
    min: 100,
    max: 3000,
  );

  return _FaderHost(
    duration: Duration(milliseconds: ms.toInt()),
  );
}
