import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:status_bar_chameleon/status_bar_chameleon.dart'
    show StatusBarChameleon;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('toggle status bar', (tester) async {
    // Hide
    await StatusBarChameleon.setStatusBarHidden(hidden: true);

    await tester.pump(const Duration(seconds: 1));

    // Show
    await StatusBarChameleon.setStatusBarHidden(hidden: false);

    await tester.pump(const Duration(seconds: 1));

    // If no exceptions → pass
    expect(true, true);
  });
}
