// programs/creature_comfort/lib/src/firebase/since_when_crud.dart
// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creature_comfort/src/typedef.dart' show Json;

const String _kCollection = 'shared';
const String _kDocument = 'since_when';
const String _kField = 'payload';

/// CRUD access to the single shared document `shared/since_when`,
/// whose `payload` field holds the encoded SinceWhen JSON string.
class SinceWhenCrud {
  SinceWhenCrud({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Json> get _doc =>
      _firestore.collection(_kCollection).doc(_kDocument);

  /// C — Create. Overwrites `shared/since_when` so [payload] becomes the
  /// single source of truth, and creates the document if it does not yet
  /// exist. Any other fields on the document are wiped by design.
  Future<void> create(String payload) {
    return _doc.set(<String, dynamic>{_kField: payload});
  }

  /// R — Read. Returns the stored `payload` string, or `null` when the
  /// document does not exist or holds no payload.
  Future<String?> read() async {
    final snapshot = await _doc.get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    return data[_kField] as String?;
  }

    /// D — Delete. Removes `shared/since_when`. Document deletion is
  /// idempotent, so deleting an absent document is a silent no-op.
  Future<void> delete() {
    return _doc.delete();
  }

}
