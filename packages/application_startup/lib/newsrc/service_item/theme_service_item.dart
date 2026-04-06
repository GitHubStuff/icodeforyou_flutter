// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/service_item/service_items.dart';
import 'package:theme_manager/theme_manager.dart' show DefaultThemeCubit;

class ThemeServiceItem extends BaseServiceItem<DefaultThemeCubit> {
  ThemeServiceItem({required super.name, required super.usingProvider});

  @override
  Future<DefaultThemeCubit> create() async => DefaultThemeCubit();

  @override
  List<String> dependencies = [];
}
