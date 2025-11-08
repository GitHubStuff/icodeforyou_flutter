// firestore_feeding_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/feeding_data.dart';
import '../../domain/repositories/feeding_repository.dart';

/// Firestore implementation of FeedingRepository
/// Single Responsibility: Handle Firestore operations for feeding data
class FirestoreFeedingService implements FeedingRepository {
  static const String _collectionName = 'feedingData';
  static const String _documentId = 'current';

  final FirebaseFirestore _firestore;

  FirestoreFeedingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _document =>
      _firestore.collection(_collectionName).doc(_documentId);

  @override
  Future<FeedingData?> getCurrentFeeding() async {
    try {
      final snapshot = await _document.get();
      if (snapshot.exists && snapshot.data() != null) {
        return FeedingData.fromMap(snapshot.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get feeding data: $e');
    }
  }

  @override
  Future<void> updateFeeding(FeedingData data) async {
    try {
      await _document.set(data.toMap());
    } catch (e) {
      throw Exception('Failed to update feeding data: $e');
    }
  }

  @override
  Stream<FeedingData?> watchFeeding() {
    return _document.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return FeedingData.fromMap(snapshot.data()!);
      }
      return null;
    });
  }
}
