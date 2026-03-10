// lib/package/since_when/_mock_data.dart

import 'package:since_when/since_when.dart';

/// Mock data generator for Widgetbook demos.
class MockDataGenerator {
  MockDataGenerator._();

  static int _idCounter = 1;
  static int _timestampCounter = 0;
  static final Map<String, TagDefinition> _tagCache = {};

  static String _generateTimestamp() {
    _timestampCounter++;
    final now = DateTime.utc(
      2025,
      1,
      19,
      10,
    ).add(Duration(seconds: _timestampCounter));
    return now.toIso8601String();
  }

  static TagDefinition _getOrCreateTag(String tagName) {
    return _tagCache.putIfAbsent(tagName, () {
      final timestamp = _generateTimestamp();
      return TagDefinition(
        id: _idCounter++,
        createdTimeStamp: timestamp,
        tagName: tagName,
        color: _colorForTag(tagName),
      );
    });
  }

  static int _colorForTag(String tagName) {
    const colors = [
      0xFF2196F3,
      0xFF4CAF50,
      0xFFF44336,
      0xFF9C27B0,
      0xFFFF9800,
      0xFF00BCD4,
      0xFFE91E63,
      0xFF795548,
    ];
    return colors[tagName.hashCode.abs() % colors.length];
  }

  /// Creates TagDefinition list from tag names.
  static List<TagDefinition> createTags(List<String> tagNames) {
    return tagNames.map(_getOrCreateTag).toList();
  }

  /// Creates a mock SinceWhenRecord.
  static SinceWhenRecord createRecord({
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tagNames,
    String? parentTimeStamp,
    int sequenceNumber = 0,
  }) {
    final timestamp = _generateTimestamp();
    return SinceWhenRecord(
      id: _idCounter++,
      createdTimeStamp: timestamp,
      reviewedTimeStamp: timestamp,
      editedTimeStamp: timestamp,
      metaData: metaData,
      dataString: dataString,
      category: category,
      tags: createTags(tagNames),
      parentTimeStamp: parentTimeStamp,
      sequenceNumber: sequenceNumber,
    );
  }

  /// Resets all counters and caches.
  static void reset() {
    _idCounter = 1;
    _timestampCounter = 0;
    _tagCache.clear();
  }
}
