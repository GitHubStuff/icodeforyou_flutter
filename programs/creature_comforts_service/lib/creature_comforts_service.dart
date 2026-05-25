// packages/creature_comforts_service/lib/creature_comforts_service.dart
// ignore_for_file: comment_references

/// Shared "last fed" timestamp service.
///
/// Exposes the [LastFedService] interface, its sealed [LastFedFailure]
/// hierarchy, and the Firestore-backed implementation [LastFedServiceFirestore].
///
/// Programs depend on the interface; the implementation is registered with
/// the services broker at app startup.
library;

export 'src/critters_status.dart';
export 'src/failures/last_fed_failure.dart';
export 'src/last_fed_service.dart';
export 'src/last_fed_service_firestore.dart';
