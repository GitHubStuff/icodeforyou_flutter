import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:statusbar/statusbar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('toggle status bar', (tester) async {
    // Hide
    await StatusBar.setStatusBarHidden(hidden: true);

    await tester.pump(const Duration(seconds: 1));

    // Show
    await StatusBar.setStatusBarHidden(hidden: false);

    await tester.pump(const Duration(seconds: 1));

    // If no exceptions → pass
    expect(true, true);
  });
}
