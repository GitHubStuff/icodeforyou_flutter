// packages/dual_selection/test/src/dual_selecction_test.dart

import 'package:dual_selection/dual_selection.dart'
    show DualSelection, DualSelectionEnum;
import 'package:dual_selection/src/defaults.dart' show Defaults;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const firstKey = Key('first');
  const secondKey = Key('second');
  const firstChildKey = Key('firstChild');
  const secondChildKey = Key('secondChild');
  const borderColor = Color(0xFF123456);

  late List<String> hapticCalls;

  setUp(() {
    hapticCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method.startsWith('HapticFeedback.')) {
            hapticCalls.add(call.method);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget buildSubject({
    DualSelectionEnum? selection,
    Duration? fadeDuration,
    double? cornerRadius,
    double? borderWidth,
    double? headerHeight,
    double? bodyHeight,
    double? width,
    ValueChanged<DualSelectionEnum>? onSelectionChanged,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: DualSelection(
          first: const ColoredBox(key: firstKey, color: Color(0xFFFF0000)),
          second: const ColoredBox(key: secondKey, color: Color(0xFF00FF00)),
          firstChild: const ColoredBox(
            key: firstChildKey,
            color: Color(0xFF0000FF),
          ),
          secondChild: const ColoredBox(
            key: secondChildKey,
            color: Color(0xFFFFFF00),
          ),
          borderColor: borderColor,
          selection: selection ?? Defaults.kFirstSelection,
          fadeDuration: fadeDuration ?? Defaults.kFadeDuration,
          cornerRadius: cornerRadius ?? Defaults.kCornerRadius,
          borderWidth: borderWidth ?? Defaults.kBorderWidth,
          headerHeight: headerHeight ?? Defaults.kHeaderHeight,
          bodyHeight: bodyHeight ?? Defaults.kBodyHeight,
          width: width ?? Defaults.kWidth,
          onSelectionChanged: onSelectionChanged,
        ),
      ),
    );
  }

  Finder inSubject(Finder matching) =>
      find.descendant(of: find.byType(DualSelection), matching: matching);

  AnimatedCrossFade crossFade(WidgetTester tester) => tester
      .widget<AnimatedCrossFade>(inSubject(find.byType(AnimatedCrossFade)));

  group('DualSelection', () {
    group('construction', () {
      test('applies shared defaults', () {
        const subject = DualSelection(
          first: SizedBox.shrink(),
          second: SizedBox.shrink(),
          firstChild: SizedBox.shrink(),
          secondChild: SizedBox.shrink(),
          borderColor: borderColor,
        );

        expect(subject.selection, Defaults.kFirstSelection);
        expect(subject.fadeDuration, Defaults.kFadeDuration);
        expect(subject.cornerRadius, Defaults.kCornerRadius);
        expect(subject.haptic, Defaults.kHaptic);
        expect(subject.borderWidth, Defaults.kBorderWidth);
        expect(subject.headerHeight, Defaults.kHeaderHeight);
        expect(subject.bodyHeight, Defaults.kBodyHeight);
        expect(subject.width, Defaults.kWidth);
        expect(subject.onSelectionChanged, isNull);
      });

      test('throws when cornerRadius is negative', () {
        expect(
          () => DualSelection(
            first: const SizedBox.shrink(),
            second: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            secondChild: const SizedBox.shrink(),
            borderColor: borderColor,
            cornerRadius: -1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when borderWidth is negative', () {
        expect(
          () => DualSelection(
            first: const SizedBox.shrink(),
            second: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            secondChild: const SizedBox.shrink(),
            borderColor: borderColor,
            borderWidth: -1,
          ),
          throwsAssertionError,
        );
      });

      test('throws when headerHeight is not positive', () {
        expect(
          () => DualSelection(
            first: const SizedBox.shrink(),
            second: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            secondChild: const SizedBox.shrink(),
            borderColor: borderColor,
            headerHeight: 0,
          ),
          throwsAssertionError,
        );
      });

      test('throws when bodyHeight is not positive', () {
        expect(
          () => DualSelection(
            first: const SizedBox.shrink(),
            second: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            secondChild: const SizedBox.shrink(),
            borderColor: borderColor,
            bodyHeight: 0,
          ),
          throwsAssertionError,
        );
      });

      test('throws when width is not positive', () {
        expect(
          () => DualSelection(
            first: const SizedBox.shrink(),
            second: const SizedBox.shrink(),
            firstChild: const SizedBox.shrink(),
            secondChild: const SizedBox.shrink(),
            borderColor: borderColor,
            width: 0,
          ),
          throwsAssertionError,
        );
      });
    });

    group('layout', () {
      testWidgets('renders both header buttons and both bodies', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject());

        expect(find.byKey(firstKey), findsOneWidget);
        expect(find.byKey(secondKey), findsOneWidget);
        expect(find.byKey(firstChildKey), findsOneWidget);
        expect(find.byKey(secondChildKey), findsOneWidget);
      });

      testWidgets('lays out each header button to width / 2 × headerHeight', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(width: 200, headerHeight: 40, bodyHeight: 100),
        );

        expect(tester.getSize(find.byKey(firstKey)), const Size(100, 40));
        expect(tester.getSize(find.byKey(secondKey)), const Size(100, 40));
      });

      testWidgets('places second to the right of first', (tester) async {
        await tester.pumpWidget(
          buildSubject(width: 200, headerHeight: 40, bodyHeight: 100),
        );

        final firstRect = tester.getRect(find.byKey(firstKey));
        final secondRect = tester.getRect(find.byKey(secondKey));

        expect(secondRect.left, firstRect.right);
        expect(secondRect.top, firstRect.top);
      });

      testWidgets('lays out each body child to width × bodyHeight', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildSubject(width: 200, headerHeight: 40, bodyHeight: 100),
        );

        expect(tester.getSize(find.byKey(firstChildKey)), const Size(200, 100));
        expect(
          tester.getSize(find.byKey(secondChildKey)),
          const Size(200, 100),
        );
      });

      testWidgets('places the body directly below the header', (tester) async {
        await tester.pumpWidget(
          buildSubject(width: 200, headerHeight: 40, bodyHeight: 100),
        );

        final headerRect = tester.getRect(find.byKey(firstKey));
        final bodyRect = tester.getRect(find.byKey(firstChildKey));

        expect(bodyRect.top, headerRect.bottom);
        expect(bodyRect.left, headerRect.left);
      });

      testWidgets(
        'renders larger than the content area by 2 × borderWidth',
        (tester) async {
          await tester.pumpWidget(
            buildSubject(
              width: 200,
              headerHeight: 40,
              bodyHeight: 100,
              borderWidth: 5,
            ),
          );

          expect(
            tester.getSize(find.byType(DualSelection)),
            const Size(210, 150),
          );
        },
      );
    });

    group('decoration', () {
      testWidgets('draws the border in borderColor at borderWidth', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(borderWidth: 5));

        final decoratedBox = tester.widget<DecoratedBox>(
          inSubject(find.byType(DecoratedBox)).first,
        );
        final decoration = decoratedBox.decoration as BoxDecoration;

        expect(decoration.border, Border.all(color: borderColor, width: 5));
      });

      testWidgets('rounds the outer border by cornerRadius', (tester) async {
        await tester.pumpWidget(buildSubject(cornerRadius: 12));

        final decoratedBox = tester.widget<DecoratedBox>(
          inSubject(find.byType(DecoratedBox)).first,
        );
        final decoration = decoratedBox.decoration as BoxDecoration;

        expect(decoration.borderRadius, BorderRadius.circular(12));
      });

      testWidgets('pads the content by borderWidth', (tester) async {
        await tester.pumpWidget(buildSubject(borderWidth: 5));

        final padding = tester.widget<Padding>(
          inSubject(find.byType(Padding)).first,
        );

        expect(padding.padding, const EdgeInsets.all(5));
      });

      testWidgets('clips the content by cornerRadius minus borderWidth', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject(cornerRadius: 12, borderWidth: 5));

        final clip = tester.widget<ClipRRect>(
          inSubject(find.byType(ClipRRect)).first,
        );

        expect(clip.borderRadius, BorderRadius.circular(7));
      });

      testWidgets('clamps the inner clip radius at zero', (tester) async {
        await tester.pumpWidget(buildSubject(cornerRadius: 2, borderWidth: 5));

        final clip = tester.widget<ClipRRect>(
          inSubject(find.byType(ClipRRect)).first,
        );

        expect(clip.borderRadius, BorderRadius.zero);
      });
    });

    group('selection', () {
      testWidgets('shows firstChild when seeded with first', (tester) async {
        await tester.pumpWidget(buildSubject(selection: .first));

        expect(crossFade(tester).crossFadeState, CrossFadeState.showFirst);
      });

      testWidgets('shows secondChild when seeded with second', (tester) async {
        await tester.pumpWidget(buildSubject(selection: .second));

        expect(crossFade(tester).crossFadeState, CrossFadeState.showSecond);
      });

      testWidgets('passes fadeDuration to the cross-fade', (tester) async {
        const duration = Duration(milliseconds: 123);

        await tester.pumpWidget(buildSubject(fadeDuration: duration));

        expect(crossFade(tester).duration, duration);
      });

      testWidgets('tapping second selects second', (tester) async {
        await tester.pumpWidget(buildSubject(selection: .first));

        await tester.tap(find.byKey(secondKey));
        await tester.pumpAndSettle();

        expect(crossFade(tester).crossFadeState, CrossFadeState.showSecond);
      });

      testWidgets('tapping first selects first', (tester) async {
        await tester.pumpWidget(buildSubject(selection: .second));

        await tester.tap(find.byKey(firstKey));
        await tester.pumpAndSettle();

        expect(crossFade(tester).crossFadeState, CrossFadeState.showFirst);
      });

      testWidgets('reports the new value through onSelectionChanged', (
        tester,
      ) async {
        final changes = <DualSelectionEnum>[];

        await tester.pumpWidget(
          buildSubject(selection: .first, onSelectionChanged: changes.add),
        );

        await tester.tap(find.byKey(secondKey));
        await tester.pumpAndSettle();

        expect(changes, [DualSelectionEnum.second]);
      });

      testWidgets('fires a haptic when the selection changes', (tester) async {
        await tester.pumpWidget(buildSubject(selection: .first));

        await tester.tap(find.byKey(secondKey));
        await tester.pumpAndSettle();

        expect(hapticCalls, hasLength(1));
      });

      testWidgets('works without onSelectionChanged', (tester) async {
        await tester.pumpWidget(buildSubject(selection: .first));

        await tester.tap(find.byKey(secondKey));
        await tester.pumpAndSettle();

        expect(crossFade(tester).crossFadeState, CrossFadeState.showSecond);
      });

      testWidgets('tapping the selected button is a no-op', (tester) async {
        final changes = <DualSelectionEnum>[];

        await tester.pumpWidget(
          buildSubject(selection: .first, onSelectionChanged: changes.add),
        );

        await tester.tap(find.byKey(firstKey));
        await tester.pumpAndSettle();

        expect(changes, isEmpty);
        expect(hapticCalls, isEmpty);
        expect(crossFade(tester).crossFadeState, CrossFadeState.showFirst);
      });

      testWidgets('owns the selection after first build', (tester) async {
        await tester.pumpWidget(buildSubject(selection: .first));
        await tester.tap(find.byKey(secondKey));
        await tester.pumpAndSettle();

        await tester.pumpWidget(buildSubject(selection: .first));
        await tester.pumpAndSettle();

        expect(crossFade(tester).crossFadeState, CrossFadeState.showSecond);
      });
    });
  });
}
