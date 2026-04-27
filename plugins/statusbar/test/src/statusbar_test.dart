import 'package:flutter_test/flutter_test.dart';
import 'package:statusbar/src/statusbar.dart';

void main() {
  test('setStatusBarHidden does not throw', () async {
    await StatusBar.setStatusBarHidden(hidden: true);
    await StatusBar.setStatusBarHidden(hidden: false);
  });
}
