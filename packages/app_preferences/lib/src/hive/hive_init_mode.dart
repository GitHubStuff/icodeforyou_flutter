// preferences/lib/src/hive/hive_init_mode.dart

// ignore_for_file: comment_references

/// Storage location strategy for [HivePreferences.init].
enum HiveInitMode {
  /// System temp directory, auto-reclaimed by the OS. For tests.
  test,

  /// Application documents directory. Backed up on iOS/iCloud.
  productionDocuments,

  /// Application support directory. Not backed up on iOS.
  productionSupport,

  /// Caller-supplied path.
  custom,
}
