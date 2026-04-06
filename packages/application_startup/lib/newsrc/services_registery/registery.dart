// ignore_for_file: public_member_api_docs

import 'package:application_startup/newsrc/errors/errors.dart' show DuplicateServiceItem;
import 'package:application_startup/newsrc/service_item/base_service_item.dart' show BaseServiceItem;

class Registery {
  static final Map<String, BaseServiceItem> _registry = {};

  static void addItem(String name, BaseServiceItem item) {
    if (_registry[name] != null) throw DuplicateServiceItem(name);
    _registry[name] = item;
  }

  static BaseServiceItem getItem(String name) {
    final item = _registry[name];
    if (item != null) return item;
    throw UnimplementedError(name);
  }
}
