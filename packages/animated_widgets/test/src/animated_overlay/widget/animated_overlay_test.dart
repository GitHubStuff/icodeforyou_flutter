// animated_widgets/test/src/animated_overlay/widget/animated_overlay_test.dart

import 'package:animated_widgets/src/animated_overlay/cubit/animated_overlay_cubit.dart';
import 'package:animated_widgets/src/animated_overlay/widget/animated_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  //
  // We wrap with MaterialApp + Scaffold (the standard testing harness). That
  // brings extra Opacity widgets into the tree from page-transition machinery,
  // so all Opacity / ColoredBox / Center lookups for the overlay subtree are
  // scoped via descendant finders rooted at Positioned -- which is unique to
  // the overlay subtree.
  //
  // Note on the platform channel: StatusBarChameleon.setStatusBarHidden short-
  // circuits on non-iOS/Android hosts (`if (!Platform.isIOS &&
  // !Platform.isAndroid) return;`), so the test host (macOS/Linux) never hits
  // the MethodChannel. No mocking required.
  // ---------------------------------------------------------------------------

  Widget wrap({required AnimatedOverlayCubit cubit, Widget? child}) {
    return MaterialApp(
      home: BlocProvider<AnimatedOverlayCubit>.value(
        value: cubit,
        child: Scaffold(
          body: AnimatedOverlay(child: child),
        ),
      ),
    );
  }

  // Scoped finders -- the only Positioned in the tree belongs to the overlay
  // subtree, so we descend from it to disambiguate against the framework's
  // internal Opacity / Center widgets dragged in by MaterialApp.
  Finder overlayOpacity() => find.descendant(
        of: find.byType(Positioned),
        matching: find.byType(Opacity),
      );

  Finder overlayColoredBox() => find.descendant(
        of: find.byType(Positioned),
        matching: find.byType(ColoredBox),
      );

  Finder overlayCenter() => find.descendant(
        of: find.byType(Positioned),
        matching: find.byType(Center),
      );

  group('AnimatedOverlay', () {
    testWidgets(
      'renders only the parent child when no overlay is present',
      (tester) async {
        final cubit = AnimatedOverlayCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(
          wrap(cubit: cubit, child: const Text('parent')),
        );

        expect(find.text('parent'), findsOneWidget);
        // No overlay means no Positioned subtree.
        expect(find.byType(Positioned), findsNothing);
      },
    );

    testWidgets(
      'omits the parent child when constructed with a null child',
      (tester) async {
        // Exercises the `?child` collection-if-null spread in the Stack.
        final cubit = AnimatedOverlayCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(wrap(cubit: cubit));

        expect(find.byType(Stack), findsWidgets);
        expect(find.byType(Positioned), findsNothing);
      },
    );

    testWidgets(
      'renders the overlay child wrapped in Opacity, ColoredBox, and Center',
      (tester) async {
        final cubit = AnimatedOverlayCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(
          wrap(cubit: cubit, child: const Text('parent')),
        );

        cubit.showOverlay(const Text('overlay'));
        await tester.pumpAndSettle();

        expect(find.text('parent'), findsOneWidget);
        expect(find.text('overlay'), findsOneWidget);

        // The overlay subtree: Positioned.fill > Opacity > ColoredBox > Center.
        expect(find.byType(Positioned), findsOneWidget);

        final opacity = tester.widget<Opacity>(overlayOpacity());
        expect(opacity.opacity, 1.0);

        final colored = tester.widget<ColoredBox>(overlayColoredBox());
        expect(colored.color, Colors.black);

        expect(overlayCenter(), findsOneWidget);
      },
    );

    testWidgets(
      'reflects opacity changes from the cubit',
      (tester) async {
        final cubit = AnimatedOverlayCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(wrap(cubit: cubit));

        cubit.showOverlay(const Text('overlay'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Opacity>(overlayOpacity()).opacity,
          1.0,
        );

        cubit.emit(cubit.state.copyWith(opacity: 0.4));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Opacity>(overlayOpacity()).opacity,
          0.4,
        );
      },
    );

    testWidgets(
      'transitions overlay on and off',
      (tester) async {
        // Drives the BlocListener through both null<->non-null transitions,
        // covering listenWhen and the listener body.
        final cubit = AnimatedOverlayCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(wrap(cubit: cubit));

        cubit.showOverlay(const Text('overlay'));
        await tester.pumpAndSettle();
        expect(find.byType(Positioned), findsOneWidget);
        expect(find.text('overlay'), findsOneWidget);

        cubit.removeOverlay();
        await tester.pumpAndSettle();
        expect(find.byType(Positioned), findsNothing);
      },
    );

    testWidgets(
      'swapping the overlay child does not toggle the listener',
      (tester) async {
        // Exercises the listenWhen branch where prev.child and curr.child are
        // both non-null -- the predicate must short-circuit and the listener
        // body must not run.
        final cubit = AnimatedOverlayCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(wrap(cubit: cubit));

        cubit.showOverlay(const Text('first'));
        await tester.pumpAndSettle();
        expect(find.text('first'), findsOneWidget);

        cubit.updateOverlay(const Text('second'));
        await tester.pumpAndSettle();

        expect(find.text('second'), findsOneWidget);
      },
    );
  });
}
