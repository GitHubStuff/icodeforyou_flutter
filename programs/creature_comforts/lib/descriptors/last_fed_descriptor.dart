// programs/creature_comforts/lib/descriptors/last_fed_descriptor.dart
// ignore_for_file: public_member_api_docs

import 'package:creature_comforts_service/creature_comforts_service.dart' show LastFedService, LastFedServiceFirestore;
import 'package:service_locator/service_locator.dart';

/// Service-locator descriptor for [LastFedService].
///
/// Registers a [LastFedServiceFirestore] as a synchronous singleton.
/// The constructor reads `FirebaseFirestore.instance`, which is
/// initialized by `Firebase.initializeApp()` in `main.dart` before this
/// descriptor fires.
class LastFedServiceDescriptor extends SyncServiceDescriptor<LastFedService> {
  const LastFedServiceDescriptor();

  /// Canonical name. Use this everywhere instead of the literal string.
  static const String kName = 'LastFedService';

  @override
  String get name => kName;

  @override
  LastFedService Function() get builder => LastFedServiceFirestore.new;
}
