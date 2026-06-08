// programs/whatever/lib/src/widgets_page.dart
// ignore_for_file: library_private_types_in_public_api, public_member_api_docs

import 'dart:async';

import 'package:animated_widgets/animated_widgets.dart'
    show
        AnimatedBarrier,
        AnimationTween,
        CombinationAnimation,
        CombinationAnimationX,
        PopoverHandle,
        PulseConfig,
        TimedWidget;
import 'package:flutter/material.dart';
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;

const double _iconSize = 50.1;

const TextStyle _style = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w500,
  color: Colors.purple,
);

PulseConfig get examplePulseConfig => const PulseConfig(
  growCurve: Curves.decelerate,
  growDuration: Duration(seconds: 1),
  holdDuration: Duration(seconds: 1, milliseconds: 30),
  pulsePeakScale: 1.9,
  pulseRestScale: 0.5,
  shrinkCurve: Curves.bounceInOut,
  shrinkDuration: Duration(milliseconds: 750),
);

//++++++++++++
class WidgetsPage extends StatefulWidget {
  const WidgetsPage({super.key});

  @override
  State<WidgetsPage> createState() => _WidgetsPage();
}

//++++++++++++
class _WidgetsPage extends State<WidgetsPage> {
  late PopoverHandle? _popoverHandle;
  late PopoverHandle? _statusBarPopover;
  Key? _comboKey;

  int pulseKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widgets Page')),
      body: Column(
        spacing: 8,
        children: [
          Wrap(
            spacing: 8,
            children: [
              _animatedBarrier(context),
              Center(
                child: const FlutterLogo(size: 200).combinationAnimation(
                  scale: AnimationTween.up(finish: 0.9),
                ),
              ),
              _animatedBarrierAsync(context),
              _toggleWidget,
              _comboButton,
            ],
          ),

          // PulseSequence(
          //   key: ValueKey(pulseKey),
          //   config: examplePulseConfig,
          //   child: const FlutterLogo(size: 150),
          // ),
          // FilledButton.icon(
          //   onPressed: () => setState(() => pulseKey++),
          //   icon: const Icon(Icons.replay),
          //   label: const Text('Replay'),
          // ),
          _comboAnimation,
        ],
      ),
    );
  }

  //+
  Widget _animatedBarrier(BuildContext context) => ElevatedButton.icon(
    icon: const Icon(
      Icons.lightbulb_sharp,
      size: _iconSize,
    ),
    label: const Text(
      'Splash Demo',
      style: _style,
    ),
    onPressed: () {
      _popoverHandle = AnimatedBarrier(
        barrierColor: Colors.green,
        child: TimedWidget(
          duration: const Duration(milliseconds: 1800),
          child: const Text(
            'Splash Demo',
            style: _style,
          ),
          onFinish: () {
            _popoverHandle?.dismiss(
              onComplete: () {
                /// Popover is dismissed...
                setState(() {});
              },
            );
          },
        ),
      ).show(context);
    },
  );

  //+
  Widget _animatedBarrierAsync(BuildContext context) => ElevatedButton.icon(
    icon: const Icon(
      Icons.lightbulb_sharp,
      size: _iconSize,
    ),
    label: const Text(
      'StatusBar Splash Demo',
      style: _style,
    ),
    onPressed: () async {
      _statusBarPopover = await AnimatedBarrier(
        barrierColor: Colors.deepPurpleAccent.shade400,
        child: TimedWidget(
          duration: const Duration(milliseconds: 1500),
          child: const Text(
            'Splash Demo',
            style: _style,
          ),
          onFinish: () async {
            await _statusBarPopover?.dismissAsync(
              onComplete: () {
                /// Popover is dismissed...
                setState(() {});
              },
            );
          },
        ),
      ).showAsync(context);
    },
  );

  //-
  void _toggle() {
    unawaited(
      StatusBarChameleon.setStatusBarHidden(
        hidden: !StatusBarChameleon.isHidden,
        duration: const Duration(milliseconds: 1250),
      ),
    );
    setState(() {});
  }

  Widget get _toggleWidget => ElevatedButton.icon(
    onPressed: _toggle,
    icon: Icon(
      StatusBarChameleon.isHidden ? Icons.visibility_off : Icons.visibility,
      size: _iconSize,
    ),
    label: Text(
      StatusBarChameleon.isHidden ? 'Show Status Bar' : 'Hide Status Bar',
      style: _style,
    ),
  );

  Widget get _comboButton => ElevatedButton.icon(
    onPressed: () => setState(() => _comboKey = UniqueKey()),
    icon: const Icon(Icons.expand_more, size: _iconSize),
    label: const Text(
      'Animation Combo',
      style: _style,
    ),
  );

  Widget get _comboAnimation => _comboKey == null
      ? const SizedBox.shrink()
      : CombinationAnimation(
          key: _comboKey,
          scale: AnimationTween.up(start: 1, finish: 0.1),
          opacity: AnimationTween.up(start: 1, finish: 0.1),
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 2600),
          onComplete: () {
            debugPrint('Done');
          },
          child: const FlutterLogo(size: 150),
        );
}
