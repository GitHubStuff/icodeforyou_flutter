// test/src/startup_splash_screen_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startup_package/src/cubit/startup_cubit.dart';
import 'package:startup_package/src/startup_splash_screen.dart';

// ---------------------------------------------------------------------------
// Fake implementation — satisfies the abstract class contract.
// ---------------------------------------------------------------------------

class _FakeSplashScreen extends StartupSplashScreen {
  const _FakeSplashScreen();

  @override
  State<_FakeSplashScreen> createState() => _FakeSplashScreenState();
}

class _FakeSplashScreenState extends State<_FakeSplashScreen> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('StartupSplashScreen', () {
    testWidgets(
      'signalAnimationComplete calls cubit.signalAnimationComplete',
      (tester) async {
        final cubit = StartupCubit([]);

        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: const MaterialApp(
              home: _FakeSplashScreen(),
            ),
          ),
        );

        final screen = tester.state<_FakeSplashScreenState>(
          find.byType(_FakeSplashScreen),
        );

        screen.widget.signalAnimationComplete(screen.context);

        expect(cubit.state, isA<StartupShowLoading>());

        unawaited(cubit.close());
      },
    );
  });
}
