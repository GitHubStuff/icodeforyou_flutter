// ignore_for_file: public_member_api_docs

import 'package:creature_comfort/src/typedef.dart' show Json;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dom.freezed.dart';
part 'dom.g.dart';

@freezed
abstract class SinceWhen with _$SinceWhen {
  const factory SinceWhen({
    required int identity,
    required String caption,
    @Default(0) int timestamp,
  }) = _SinceWhen;

  factory SinceWhen.fromJson(Json json) => _$SinceWhenFromJson(json);
}

@freezed
abstract class SinceWhenUser with _$SinceWhenUser {
  const factory SinceWhenUser({
    required int userId,
    required String email,
    required String name,
    @Default([]) List<int> sinceWhenList,
  }) = _SinceWhenUser;

  factory SinceWhenUser.fromJson(Json json) => _$SinceWhenUserFromJson(json);
}

@freezed
abstract class SinceWhenParent with _$SinceWhenParent {
  const factory SinceWhenParent({
    @Default([]) List<SinceWhen> sinceWhen,
    @Default([]) List<SinceWhenUser> users,
  }) = _SinceWhenParent;

  factory SinceWhenParent.fromJson(Json json) =>
      _$SinceWhenParentFromJson(json);
}

/*
class SinceWhen {
  const SinceWhen({
    required this.identity,
    required this.timestamp,
    required this.caption,
  });

  final int identity;
  final int timestamp;
  final String caption;
}

class SinceWhenUser {
  const SinceWhenUser({
    required this.userId,
    required this.email,
    required this.name,
    this.sinceWhenList = const [],
  });
  final int userId;
  final String email;
  final String name;
  final List<int> sinceWhenList;
}

class SinceWhenParent {
  const SinceWhenParent({
    this.sinceWhen = const [],
    this.sinceWhenUsers = const [],
  });
  final List<SinceWhen> sinceWhen;
  final List<SinceWhenUser> sinceWhenUsers;

  void addEvent({required SinceWhen event}) {
    sinceWhen.add(event);
  }

  void addUser({required SinceWhenUser user}) {
    sinceWhenUsers.add(user);
  }
}

/*
RepeatingAnimationBuilder m = RepeatingAnimationBuilder(
  animatable: animatable,
  duration: duration,
  builder: builder,
);
*/
*/
