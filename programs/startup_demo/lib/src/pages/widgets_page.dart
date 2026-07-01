// programs/whatever/lib/src/widgets_page.dart

import 'dart:async';

import 'package:animated_widgets/animated_widgets.dart'
    show AnimatedBarrier, AnimatesWidgetExt, PopoverHandle, TimedWidget;
import 'package:flutter/material.dart';
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;

const double _iconSize = 50.1;

const TextStyle _style = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w500,
  color: Colors.purple,
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
                child: const FlutterLogo(size: 200).animatedSteps(),
              ),
              _animatedBarrierAsync(context),
              _toggleWidget,
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
}
