// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:creature_comfort/src/dom/dom.dart'
    show SinceWhen, SinceWhenParent, SinceWhenUser;
import 'package:creature_comfort/src/typedef.dart' show Json;
//import 'package:extensions/extensions.dart' show DateTimeExt;

SinceWhenParent _parent = const SinceWhenParent();

class SinceWhenController {
  static void addEvent(SinceWhen event) {
    //final id = (await DateTimeExt.unique()).microsecondsSinceEpoch;
    _parent = _parent.copyWith(sinceWhen: [..._parent.sinceWhen, event]);
  }

  static void addUser(SinceWhenUser user) {
    _parent = _parent.copyWith(users: [..._parent.users, user]);
  }

  static SinceWhenParent currentData() =>
      SinceWhenParent.fromJson(_parent.toJson());

  static void reset() => _parent = const SinceWhenParent();

  static Json toJson() => _parent.toJson();

  static void fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Json;
    _parent = SinceWhenParent.fromJson(json);
  }
}
