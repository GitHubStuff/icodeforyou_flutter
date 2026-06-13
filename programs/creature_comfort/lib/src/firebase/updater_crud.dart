// programs/creature_comfort/lib/src/firebase/updater_crud.dart
// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creature_comfort/src/typedef.dart' show Json;

const String _kCollection = 'shared';
const String _kDocument = 'updater';
const String _kEmailField = 'email';
const String _kNameField = 'name';
const String _kTimestampField = 'timestamp';

/// The latest change beacon from `shared/updater`: who changed something
/// last, and when.
typedef UpdaterBeacon = ({String email, String name, int timestamp});

/// Read/write access to the shared beacon document `shared/updater`.
///
/// Each write overwrites the beacon with whoever changed something last,
/// so every client listening to this document is pushed the new values.
class UpdaterCrud {
  UpdaterCrud({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Json> get _doc =>
      _firestore.collection(_kCollection).doc(_kDocument);

  /// Overwrites `shared/updater` with the latest change beacon. Creates
  /// the document if it does not yet exist.
  Future<void> write({
    required String email,
    required String name,
    required int timestamp,
  }) {
    return _doc.set(<String, dynamic>{
      _kEmailField: email,
      _kNameField: name,
      _kTimestampField: timestamp,
    });
  }

  /// A live stream of the beacon. Emits on every change to
  /// `shared/updater`, and `null` when the document does not exist.
  Stream<UpdaterBeacon?> watch() => _doc.snapshots().map(_toBeacon);

  UpdaterBeacon? _toBeacon(DocumentSnapshot<Json> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return (
      email: data[_kEmailField] as String? ?? '',
      name: data[_kNameField] as String? ?? '',
      timestamp: data[_kTimestampField] as int? ?? 0,
    );
  }
}
