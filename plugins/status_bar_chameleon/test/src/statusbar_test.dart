import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_chameleon/src/status_bar_chameleon.dart';

void main() {
  test('setStatusBarHidden does not throw', () async {
    await StatusBarChameleon.setStatusBarHidden(hidden: true);
    await StatusBarChameleon.setStatusBarHidden(hidden: false);
  });
}
