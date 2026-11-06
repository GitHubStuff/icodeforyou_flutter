// programs/since_when_dev/lib/menu_bar/menu_bar_screen.dart

import 'package:flutter/widgets.dart';
import 'package:place_holder_widget/place_holder_widget.dart';

class MenuBarScreen extends StatelessWidget {
  /// Route used bu GoRoute
  static const route = '/menu_bar_screen';
  @override
  Widget build(BuildContext context) {
    // TODO(steven): Replace with the rail/dock menus
    return PlaceHolderScreen.withString('Menu Bar Screen');
  }
}
