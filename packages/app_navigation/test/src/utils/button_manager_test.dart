// packages/app_navigation/test/src/destination/button_manager_test.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;
import 'package:app_navigation/src/utils/button_list_manager.dart'
    show ButtonListManager;
import 'package:flutter/widgets.dart' show IconData, SizedBox, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

Widget _placeholder() => const SizedBox.shrink();

/// Fixture mirroring a real dock: `more` listed first (as `values` would
/// have it), four pinned, three overflow.
enum _Items implements NavButtonProperties {
  more(NavSlot.more),
  a(NavSlot.pinned),
  b(NavSlot.pinned),
  c(NavSlot.pinned),
  d(NavSlot.pinned),
  e(NavSlot.overflow),
  f(NavSlot.overflow),
  g(NavSlot.overflow);

  const _Items(this.slot);

  @override
  final NavSlot slot;

  @override
  Widget Function() get viewBuilder => _placeholder;

  @override
  HapticIntensity get haptic => HapticIntensity.primary;

  @override
  String? get caption => null;

  @override
  IconData? get iconData => null;
}

/// Fixture with no `more` member.
enum _NoMore implements NavButtonProperties {
  a(NavSlot.pinned),
  b(NavSlot.pinned),
  c(NavSlot.overflow);

  const _NoMore(this.slot);

  @override
  final NavSlot slot;

  @override
  Widget Function() get viewBuilder => _placeholder;

  @override
  HapticIntensity get haptic => HapticIntensity.primary;

  @override
  String? get caption => null;

  @override
  IconData? get iconData => null;
}

/// Fixture with two `more` members.
enum _TwoMore implements NavButtonProperties {
  more1(NavSlot.more),
  more2(NavSlot.more),
  a(NavSlot.pinned),
  b(NavSlot.overflow);

  const _TwoMore(this.slot);

  @override
  final NavSlot slot;

  @override
  Widget Function() get viewBuilder => _placeholder;

  @override
  HapticIntensity get haptic => HapticIntensity.primary;

  @override
  String? get caption => null;

  @override
  IconData? get iconData => null;
}

const double _button = 80;

/// Width that holds exactly [count] buttons of [_button].
double _widthFor(int count) => _button * count;

ButtonListManager<_Items> _manager(double width) => ButtonListManager<_Items>(
  buttons: _Items.values,
  width: width,
  buttonWidth: _button,
);

void main() {
  group('ButtonManager', () {
    group('everything fits', () {
      const pinnedOnly = [
        _Items.more,
        _Items.a,
        _Items.b,
        _Items.c,
        _Items.d,
      ];

      test('returns all pinned and no overflow, more unused', () {
        final manager = ButtonListManager<_Items>(
          buttons: pinnedOnly,
          width: _widthFor(4),
          buttonWidth: _button,
        );

        expect(manager.fitted(), [_Items.a, _Items.b, _Items.c, _Items.d]);
        expect(manager.overflow(), isEmpty);
      });

      test('ignores a missing more when it is not needed', () {
        final manager = ButtonListManager<_NoMore>(
          buttons: const [_NoMore.a, _NoMore.b],
          width: _widthFor(2),
          buttonWidth: _button,
        );

        expect(manager.fitted(), [_NoMore.a, _NoMore.b]);
        expect(manager.overflow(), isEmpty);
      });

      test('spare room does not promote overflow slots', () {
        final manager = _manager(_widthFor(10));

        expect(
          manager.fitted(),
          [_Items.a, _Items.b, _Items.c, _Items.d, _Items.more],
        );
        expect(manager.overflow(), [_Items.e, _Items.f, _Items.g]);
      });

      test('an empty list yields empty partitions', () {
        final manager = ButtonListManager<_Items>(
          buttons: const [],
          width: _widthFor(1),
          buttonWidth: _button,
        );

        expect(manager.fitted(), isEmpty);
        expect(manager.overflow(), isEmpty);
      });
    });

    group('pinned fit with more', () {
      test('appends more last and overflow keeps list order', () {
        final manager = _manager(_widthFor(5));

        expect(
          manager.fitted(),
          [_Items.a, _Items.b, _Items.c, _Items.d, _Items.more],
        );
        expect(manager.overflow(), [_Items.e, _Items.f, _Items.g]);
      });

      test('counts whole buttons only', () {
        final manager = _manager(_widthFor(5) + _button - 1);

        expect(manager.fitted().length, 5);
      });
    });

    group('pinned do not fit', () {
      test('demotes trailing pinned ahead of overflow slots', () {
        final manager = _manager(_widthFor(4));

        expect(manager.fitted(), [_Items.a, _Items.b, _Items.c, _Items.more]);
        expect(
          manager.overflow(),
          [_Items.d, _Items.e, _Items.f, _Items.g],
        );
      });

      test('requires more even when no overflow slots exist', () {
        final manager = ButtonListManager<_Items>(
          buttons: const [_Items.more, _Items.a, _Items.b, _Items.c],
          width: _widthFor(2),
          buttonWidth: _button,
        );

        expect(manager.fitted(), [_Items.a, _Items.more]);
        expect(manager.overflow(), [_Items.b, _Items.c]);
      });

      test('zero room leaves more as the only fitted button', () {
        final manager = _manager(_widthFor(1));

        expect(manager.fitted(), [_Items.more]);
        expect(
          manager.overflow(),
          [
            _Items.a,
            _Items.b,
            _Items.c,
            _Items.d,
            _Items.e,
            _Items.f,
            _Items.g,
          ],
        );
      });
    });

    group('errors', () {
      test(
        'throws StateError when width holds no button and overflow exists',
        () {
          expect(() => _manager(_button - 1), throwsStateError);
        },
      );

      test('throws StateError when more is needed but absent', () {
        expect(
          () => ButtonListManager<_NoMore>(
            buttons: _NoMore.values,
            width: _widthFor(3),
            buttonWidth: _button,
          ),
          throwsStateError,
        );
      });

      test('throws StateError when more than one more exists', () {
        expect(
          () => ButtonListManager<_TwoMore>(
            buttons: _TwoMore.values,
            width: _widthFor(3),
            buttonWidth: _button,
          ),
          throwsStateError,
        );
      });

      test('throws UnsupportedError for zero buttonWidth', () {
        expect(
          () => ButtonListManager<_Items>(
            buttons: _Items.values,
            width: _widthFor(4),
            buttonWidth: 0,
          ),
          throwsUnsupportedError,
        );
      });

      test('throws UnsupportedError for negative buttonWidth', () {
        expect(
          () => ButtonListManager<_Items>(
            buttons: _Items.values,
            width: _widthFor(4),
            buttonWidth: -1,
          ),
          throwsUnsupportedError,
        );
      });
    });

    group('immutability', () {
      test('fitted is unmodifiable', () {
        final manager = _manager(_widthFor(4));

        expect(() => manager.fitted().add(_Items.a), throwsUnsupportedError);
      });

      test('overflow is unmodifiable', () {
        final manager = _manager(_widthFor(4));

        expect(
          () => manager.overflow().add(_Items.a),
          throwsUnsupportedError,
        );
      });

      test('mutating the input list after construction has no effect', () {
        final buttons = [..._Items.values];
        final manager = ButtonListManager<_Items>(
          buttons: buttons,
          width: _widthFor(4),
          buttonWidth: _button,
        );

        buttons.clear();

        expect(manager.fitted(), [_Items.a, _Items.b, _Items.c, _Items.more]);
      });
    });
  });
}
