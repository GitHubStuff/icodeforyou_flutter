// programs/since_when_dev/lib/main.dart

import 'package:flutter/widgets.dart' show WidgetsFlutterBinding, runApp;
import 'package:since_when_dev/injection/injection.dart'
    show configureDependencies;
import 'package:since_when_dev/main_app/masterial_app_router.dart'
    show MasterialAppRouter;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MasterialAppRouter());
}
