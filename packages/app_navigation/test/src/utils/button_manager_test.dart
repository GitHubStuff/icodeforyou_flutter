// packages/app_navigation/test/src/utils/button_list_manager_test.dart

import 'package:app_navigation/app_navigation.dart'
    show NavButtonProperties, NavSlot;
import 'package:app_navigation/src/utils/button_list_manager.dart'
    show ButtonListManager;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haptic_intensity/haptic_intensity.dart' show HapticIntensity;

Widget _view() => const SizedBox.shrink();

enum _Item implements NavButtonProperties {
  more(NavSlot.more),
  otherMore(NavSlot.more),
  home(NavSlot.pinned),
  tools(NavSlot.pinned),
  pingPong(NavSlot.pinned),
  settings(NavSlot.pinned),
  spinDemo(NavSlot.overflow),
  database(NavSlot.overflow);

  const _Item(this.slot);

  @override
  final NavSlot slot;

  @override
  IconData? get iconData => null;

  @override
  String? get caption => name;

  @override
  HapticIntensity get haptic => HapticIntensity.primary;

  @override
  Widget Function() get viewBuilder => _view;
}

const double _buttonWidth = 80;

double _slots(int count) => _buttonWidth * count;

ButtonListManager<_Item> _manager({_Item more = _Item.more}) =>
    ButtonListManager<_Item>(more: more, buttonWidth: _buttonWidth);

void main() {
  group('ButtonListManager constructor', () {
    test('rejects a more that does not have NavSlot.more', () {
      expect(() => _manager(more: _Item.home), throwsArgumentError);
    });

    test('rejects a zero buttonWidth', () {
      expect(
        () => ButtonListManager<_Item>(more: _Item.more, buttonWidth: 0),
        throwsArgumentError,
      );
    });

    test('rejects a negative buttonWidth', () {
      expect(
        () => ButtonListManager<_Item>(more: _Item.more, buttonWidth: -1),
        throwsArgumentError,
      );
    });

    test('exposes more and buttonWidth', () {
      final manager = _manager();
      expect(manager.more, _Item.more);
      expect(manager.buttonWidth, _buttonWidth);
    });
  });

  group('ButtonListManager.organize validation', () {
    test('rejects an empty list', () {
      expect(() => _manager().organize(const [], _slots(3)), throwsStateError);
    });

    test('rejects a NavSlot.more destination other than more', () {
      expect(
        () => _manager().organize(
          const [_Item.home, _Item.otherMore],
          _slots(3),
        ),
        throwsStateError,
      );
    });

    test('rejects an edgeSize narrower than one button', () {
      expect(
        () => _manager().organize(const [_Item.home], _buttonWidth - 1),
        throwsStateError,
      );
    });

    test('rejects a zero edgeSize', () {
      expect(
        () => _manager().organize(const [_Item.home], 0),
        throwsStateError,
      );
    });
  });

  group('ButtonListManager.organize without overflow', () {
    test('returns pinned destinations unchanged when they all fit', () {
      final result = _manager().organize(
        const [_Item.home, _Item.tools, _Item.pingPong],
        _slots(3),
      );
      expect(result, const [_Item.home, _Item.tools, _Item.pingPong]);
    });

    test('returns pinned destinations when room is left over', () {
      final result = _manager().organize(
        const [_Item.home, _Item.tools],
        _slots(5),
      );
      expect(result, const [_Item.home, _Item.tools]);
    });

    test('omits an explicit more listed last with nothing to demote', () {
      final result = _manager().organize(
        const [_Item.home, _Item.tools, _Item.more],
        _slots(3),
      );
      expect(result, const [_Item.home, _Item.tools]);
    });

    test('fits exactly capacity pinned destinations without more', () {
      final result = _manager().organize(
        const [_Item.home, _Item.tools, _Item.pingPong],
        _slots(3) + _buttonWidth - 1,
      );
      expect(result, const [_Item.home, _Item.tools, _Item.pingPong]);
    });

    test('returns a single destination on a single-slot surface', () {
      final result = _manager().organize(const [_Item.home], _slots(1));
      expect(result, const [_Item.home]);
    });

    test('returns an unmodifiable list', () {
      final result = _manager().organize(const [_Item.home], _slots(1));
      expect(() => result.add(_Item.tools), throwsUnsupportedError);
    });
  });

  group('ButtonListManager.organize with implicit more', () {
    test('pulls more into the last slot when pinned overflow', () {
      final result = _manager().organize(
        const [_Item.home, _Item.tools, _Item.pingPong, _Item.settings],
        _slots(3),
      );
      expect(result, const [
        _Item.home,
        _Item.tools,
        _Item.more,
        _Item.pingPong,
        _Item.settings,
      ]);
    });

    test('demotes the last pinned when an overflow destination exists', () {
      final result = _manager().organize(
        const [_Item.home, _Item.tools, _Item.pingPong, _Item.spinDemo],
        _slots(3),
      );
      expect(result, const [
        _Item.home,
        _Item.tools,
        _Item.more,
        _Item.pingPong,
        _Item.spinDemo,
      ]);
    });

    test('keeps demoted pinned and overflow in list order', () {
      final result = _manager().organize(
        const [
          _Item.home,
          _Item.tools,
          _Item.pingPong,
          _Item.spinDemo,
          _Item.database,
          _Item.settings,
        ],
        _slots(3),
      );
      expect(result, const [
        _Item.home,
        _Item.tools,
        _Item.more,
        _Item.pingPong,
        _Item.spinDemo,
        _Item.database,
        _Item.settings,
      ]);
    });

    test('always demotes an overflow destination even when room exists', () {
      final result = _manager().organize(
        const [_Item.home, _Item.spinDemo],
        _slots(5),
      );
      expect(result, const [_Item.home, _Item.more, _Item.spinDemo]);
    });

    test('demotes an overflow destination listed first', () {
      final result = _manager().organize(
        const [_Item.spinDemo, _Item.home, _Item.tools],
        _slots(5),
      );
      expect(result, const [
        _Item.home,
        _Item.tools,
        _Item.more,
        _Item.spinDemo,
      ]);
    });

    test('puts more alone in slot zero on a single-slot surface', () {
      final result = _manager().organize(
        const [_Item.home, _Item.tools],
        _slots(1),
      );
      expect(result, const [_Item.more, _Item.home, _Item.tools]);
    });

    test('puts more alone when the only destination is overflow', () {
      final result = _manager().organize(const [_Item.spinDemo], _slots(1));
      expect(result, const [_Item.more, _Item.spinDemo]);
    });
  });

  group('ButtonListManager.organize with explicit more', () {
    test('cuts the list at more and demotes everything after it', () {
      final result = _manager().organize(
        const [_Item.home, _Item.more, _Item.tools, _Item.pingPong],
        _slots(5),
      );
      expect(result, const [
        _Item.home,
        _Item.more,
        _Item.tools,
        _Item.pingPong,
      ]);
    });

    test('pulls more forward when pinned before it overflow', () {
      final result = _manager().organize(
        const [
          _Item.home,
          _Item.tools,
          _Item.pingPong,
          _Item.settings,
          _Item.more,
          _Item.spinDemo,
        ],
        _slots(3),
      );
      expect(result, const [
        _Item.home,
        _Item.tools,
        _Item.more,
        _Item.pingPong,
        _Item.settings,
        _Item.spinDemo,
      ]);
    });

    test('demotes an overflow destination listed before more', () {
      final result = _manager().organize(
        const [_Item.home, _Item.spinDemo, _Item.tools, _Item.more],
        _slots(5),
      );
      expect(result, const [
        _Item.home,
        _Item.tools,
        _Item.more,
        _Item.spinDemo,
      ]);
    });

    test('shows more when it is last and an overflow destination exists', () {
      final result = _manager().organize(
        const [_Item.home, _Item.spinDemo, _Item.more],
        _slots(5),
      );
      expect(result, const [_Item.home, _Item.more, _Item.spinDemo]);
    });

    test('puts more alone in slot zero on a single-slot surface', () {
      final result = _manager().organize(
        const [_Item.home, _Item.more, _Item.tools],
        _slots(1),
      );
      expect(result, const [_Item.more, _Item.home, _Item.tools]);
    });

    test('omits more when it is first and alone', () {
      final result = _manager().organize(
        const [_Item.home, _Item.more],
        _slots(1),
      );
      expect(result, const [_Item.home]);
    });
  });
}
