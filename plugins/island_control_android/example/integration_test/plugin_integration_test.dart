// plugins/island_control_android/example/integration_test/plugin_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:island_control_android/island_control_android.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final islandControl = IslandControlAndroid();

  testWidgets('setIsland(isHidden: true) removes the top inset', (
    tester,
  ) async {
    await islandControl.setIsland(isHidden: true);
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.view.padding.top, 0);
  });

  testWidgets('setIsland(isHidden: false) restores the top inset', (
    tester,
  ) async {
    await islandControl.setIsland(isHidden: false);
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.view.padding.top, greaterThan(0));
  });
}
