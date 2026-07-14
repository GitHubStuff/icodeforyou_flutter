part of 'since_when.dart';

extension SinceWhenExt on SinceWhen {
  /// Runs a raw SELECT and returns each row as a column-name → value map.
  Future<List<Map<String, Object?>>> select({required String query}) async {
    final rows = await _db.customSelect(query).get();
    return rows.map((row) => row.data).toList();
  }

  /// Closes the underlying connection.
  Future<void> close() => _db.close();
}
