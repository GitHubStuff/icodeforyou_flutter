// feeding_repository.dart
import '../entities/feeding_data.dart';

/// Abstract repository for feeding data operations
/// Interface Segregation Principle: Focused on feeding operations
abstract class FeedingRepository {
  /// Get current feeding data
  Future<FeedingData?> getCurrentFeeding();

  /// Update feeding data
  Future<void> updateFeeding(FeedingData data);

  /// Stream of feeding data changes
  Stream<FeedingData?> watchFeeding();
}
