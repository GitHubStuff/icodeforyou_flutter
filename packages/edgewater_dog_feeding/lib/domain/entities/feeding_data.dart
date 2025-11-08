// feeding_data.dart

/// Feeding data entity
/// Single Responsibility: Represent feeding information
class FeedingData {
  final String name;
  final int epoc;

  const FeedingData({required this.name, required this.epoc});

  /// Create from Firestore document
  factory FeedingData.fromMap(Map<String, dynamic> map) {
    return FeedingData(
      name: map['name'] as String? ?? '',
      epoc: map['epoc'] as int? ?? 0,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {'name': name, 'epoc': epoc};
  }

  /// Create copy with updated values
  FeedingData copyWith({String? name, int? epoc}) {
    return FeedingData(name: name ?? this.name, epoc: epoc ?? this.epoc);
  }
}
