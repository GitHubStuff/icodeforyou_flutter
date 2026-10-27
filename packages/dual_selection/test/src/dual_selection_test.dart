// packages/dual_selection/test/src/dual_selection_test.dart

import 'package:dual_selection/dual_selection.dart'
    show DualSelection, DualSelectionEnum;
import 'package:dual_selection/src/defaults.dart' show Defaults;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _kFirstKey = Key('first');
const _kSecondKey = Key('second');
const _kFirstChildKey = Key('firstChild');
const _kSecondChildKey = Key('secondChild');

const _kBorderColor = Color(0xFF123456);
const _kSelectedColor = Color(0xFFAA0000);
const _kUnselectedColor = Color(0xFF00AA00);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> platformCalls;

  setUp(() {
    platformCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget buildSubject({
    DualSelectionEnum selection = Defaults.kFirstSelection,
    Duration fadeDuration = Defaults.kFadeDuration,
    double cornerRadius = Defaults.kCornerRadius,
    double borderWidth = Defaults.kBorderWidth,
    double headerHeight = Defaults.kHeaderHeight,
    double bodyHeight = Defaults.kBodyHeight,
    double width = Defaults.kWidth,
    Color? selectedHeaderColor,
    Color? unselectedHeaderColor,
    ValueChanged<DualSelectionEnum>? onSelectionChanged,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: DualSelection(
          first: const SizedBox(key: _kFirstKey),
          second: const SizedBox(key: _kSecondKey),
          firstChild: const SizedBox(key: _kFirstChildKey),
          secondChild: const SizedBox(key: _kSecondChildKey),
          borderColor: _kBorderColor,
          selectedHeaderColor: selectedHeaderColor,
          unselectedHeaderColor: unselectedHeaderColor,
          selection: selection,
          fadeDuration: fadeDuration,
          cornerRadius: cornerRadius,
          borderWidth: borderWidth,
          headerHeight: headerHeight,
          bodyHeight: bodyHeight,
          width: width,
          onSelectionChanged: onSelectionChanged,
        ),
      ),
    );
  }

  /// The tappable header button that owns the slot content with [slotKey].
  Finder headerButton(Key slotKey) => find.ancestor(
    of: find.byKey(slotKey),
    matching: find.byType(GestureDetector),
  );

  Finder headerBox(Key slotKey) => find.ancestor(
    of: find.byKey(slotKey),
    matching: find.byType(ColoredBox),
  );

  AnimatedCrossFade crossFade(WidgetTester tester) =>
      tester.widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade));

  ClipRRect outerClip(WidgetTester tester) => tester.widget<ClipRRect>(
    find
        .descendant(
          of: find.byType(DualSelection),
          matching: find.byType(ClipRRect),
        )
        .first,
  );

  group('DualSelection', () {
    group('constructor asserts', () {
      DualSelection build({
        double cornerRadius = Defaults.kCornerRadius,
        double borderWidth = Defaults.kBorderWidth,
        double headerHeight = Defaults.kHeaderHeight,
        double bodyHeight = Defaults.kBodyHeight,
        double width = Defaults.kWidth,
      }) {
        return DualSelection(
          first: const SizedBox(),
          second: const SizedBox(),
          firstChild: const SizedBox(),
          secondChild: const SizedBox(),
          borderColor: _kBorderColor,
          cornerRadius: cornerRadius,
          borderWidth: borderWidth,
          headerHeight: headerHeight,
          bodyHeight: bodyHeight,
          width: width,
        );
      }

      test('rejects negative cornerRadius', () {
        expect(() => build(cornerRadius: -1), throwsAssertionError);
      });

      test('rejects negative borderWidth', () {
        expect(() => build(borderWidth: -1), throwsAssertionError);
      });

      test('rejects non-positive headerHeight', () {
        expect(() => build(headerHeight: 0), throwsAssertionError);
      });

      test('rejects non-positive bodyHeight', () {
        expect(() => build(bodyHeight: 0), throwsAssertionError);
      });

      test('rejects non-positive width', () {
        expect(() => build(width: 0), throwsAssertionError);
      });

      test('accepts zero cornerRadius and borderWidth', () {
        expect(() => build(cornerRadius: 0, borderWidth: 0), returnsNormally);
      });
    });

    group('layout', () {
      testWidgets('rendered size is content plus border on each side', (
        tester,
      ) async {
        const borderWidth = 3.0;
        const headerHeight = 40.0;
        const bodyHeight = 100.0;
        const width = 200.0;

        await tester.pumpWidget(
          buildSubject(
            borderWidth: borderWidth,
            headerHeight: headerHeight,
            bodyHeight: bodyHeight,
            width: width,
          ),
        );

        expect(
          tester.getSize(find.byType(DualSelection)),
          const Size(
            width + 2 * borderWidth,
            headerHeight + bodyHeight + 2 * borderWidth,
          ),
        );
      });

      testWidgets('each header slot is half width by headerHeight', (
        tester,
      ) async {
        const headerHeight = 40.0;
        const width = 200.0;

        await tester.pumpWidget(
          buildSubject(headerHeight: headerHeight, width: width),
        );

        expect(
          tester.getSize(find.byKey(_kFirstKey)),
          const Size(width / 2, headerHeight),
        );
        expect(
          tester.getSize(find.byKey(_kSecondKey)),
          const Size(width / 2, headerHeight),
        );
      });

      testWidgets('each body child is width by bodyHeight', (tester) async {
        const bodyHeight = 100.0;
        const width = 200.0;

        await tester.pumpWidget(
          buildSubject(bodyHeight: bodyHeight, width: width),
        );

        expect(
          tester.getSize(find.byKey(_kFirstChildKey)),
          const Size(width, bodyHeight),
        );
        expect(
          tester.getSize(find.byKey(_kSecondChildKey)),
          const Size(width, bodyHeight),
        );
      });

      testWidgets('outer border uses borderColor, borderWidth, cornerRadius', (
        tester,
      ) async {
        const borderWidth = 4.0;
        const cornerRadius = 12.0;

        await tester.pumpWidget(
          buildSubject(borderWidth: borderWidth, cornerRadius: cornerRadius),
        );

        final decoratedBox = tester.widget<DecoratedBox>(
          find
              .descendant(
                of: find.byType(DualSelection),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        final decoration = decoratedBox.decoration as BoxDecoration;

        expect(decoration.borderRadius, BorderRadius.circular(cornerRadius));
        expect(
          decoration.border,
          Border.all(color: _kBorderColor, width: borderWidth),
        );
      });

      testWidgets('inner clip radius is cornerRadius minus borderWidth', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(cornerRadius: 12, borderWidth: 4),
        );

        expect(outerClip(tester).borderRadius, BorderRadius.circular(8));
      });

      testWidgets(
        'inner clip radius clamps to zero when border exceeds radius',
        (tester) async {
          await tester.pumpWidget(
            buildSubject(cornerRadius: 2, borderWidth: 6),
          );

          expect(outerClip(tester).borderRadius, BorderRadius.zero);
        },
      );
    });

    group('selection', () {
      testWidgets('shows first body when selection is first', (tester) async {
        await tester.pumpWidget(buildSubject());

        expect(crossFade(tester).crossFadeState, CrossFadeState.showFirst);
      });

      testWidgets('shows second body when selection is second', (tester) async {
        await tester.pumpWidget(
          buildSubject(selection: DualSelectionEnum.second),
        );

        expect(crossFade(tester).crossFadeState, CrossFadeState.showSecond);
      });

      testWidgets('passes fadeDuration to the cross-fade', (tester) async {
        const fadeDuration = Duration(milliseconds: 123);

        await tester.pumpWidget(buildSubject(fadeDuration: fadeDuration));

        expect(crossFade(tester).duration, fadeDuration);
      });

      testWidgets('tapping the other button changes selection and reports it', (
        tester,
      ) async {
        final reported = <DualSelectionEnum>[];

        await tester.pumpWidget(
          buildSubject(onSelectionChanged: reported.add),
        );

        await tester.tap(headerButton(_kSecondKey));
        await tester.pumpAndSettle();

        expect(reported, [DualSelectionEnum.second]);
        expect(crossFade(tester).crossFadeState, CrossFadeState.showSecond);
      });

      testWidgets('tapping back to first restores first body', (tester) async {
        final reported = <DualSelectionEnum>[];

        await tester.pumpWidget(
          buildSubject(
            selection: DualSelectionEnum.second,
            onSelectionChanged: reported.add,
          ),
        );

        await tester.tap(headerButton(_kFirstKey));
        await tester.pumpAndSettle();

        expect(reported, [DualSelectionEnum.first]);
        expect(crossFade(tester).crossFadeState, CrossFadeState.showFirst);
      });

      testWidgets('tapping the already-selected button is a no-op', (
        tester,
      ) async {
        final reported = <DualSelectionEnum>[];

        await tester.pumpWidget(
          buildSubject(onSelectionChanged: reported.add),
        );
        platformCalls.clear();

        await tester.tap(headerButton(_kFirstKey));
        await tester.pumpAndSettle();

        expect(reported, isEmpty);
        expect(platformCalls, isEmpty);
        expect(crossFade(tester).crossFadeState, CrossFadeState.showFirst);
      });

      testWidgets('works without onSelectionChanged', (tester) async {
        await tester.pumpWidget(buildSubject());

        await tester.tap(headerButton(_kSecondKey));
        await tester.pumpAndSettle();

        expect(crossFade(tester).crossFadeState, CrossFadeState.showSecond);
      });
    });

    group('header colours', () {
      testWidgets('paints no header background when both colours are null', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject());

        expect(headerBox(_kFirstKey), findsNothing);
        expect(headerBox(_kSecondKey), findsNothing);
      });

      testWidgets('paints selected and unselected colours on the right slots', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            selectedHeaderColor: _kSelectedColor,
            unselectedHeaderColor: _kUnselectedColor,
          ),
        );

        expect(
          tester.widget<ColoredBox>(headerBox(_kFirstKey)).color,
          _kSelectedColor,
        );
        expect(
          tester.widget<ColoredBox>(headerBox(_kSecondKey)).color,
          _kUnselectedColor,
        );
      });

      testWidgets('swaps header colours when selection changes', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(
            selectedHeaderColor: _kSelectedColor,
            unselectedHeaderColor: _kUnselectedColor,
          ),
        );

        await tester.tap(headerButton(_kSecondKey));
        await tester.pumpAndSettle();

        expect(
          tester.widget<ColoredBox>(headerBox(_kFirstKey)).color,
          _kUnselectedColor,
        );
        expect(
          tester.widget<ColoredBox>(headerBox(_kSecondKey)).color,
          _kSelectedColor,
        );
      });

      testWidgets('paints only the selected slot when unselected is null', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(selectedHeaderColor: _kSelectedColor),
        );

        expect(
          tester.widget<ColoredBox>(headerBox(_kFirstKey)).color,
          _kSelectedColor,
        );
        expect(headerBox(_kSecondKey), findsNothing);
      });

      testWidgets('paints only the unselected slot when selected is null', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(unselectedHeaderColor: _kUnselectedColor),
        );

        expect(headerBox(_kFirstKey), findsNothing);
        expect(
          tester.widget<ColoredBox>(headerBox(_kSecondKey)).color,
          _kUnselectedColor,
        );
      });
    });
  });
}
