// test/widget_themes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_themes/widget_themes.dart';

void main() {
  test('barrel exports CrossFadeTheme with its documented defaults', () {
    const theme = CrossFadeTheme();
    expect(theme, isA<CrossFadeTheme>());
    expect(theme.crossFadeDuration, const Duration(milliseconds: 1250));
    expect(theme.buttonSize, 48);
  });
}
