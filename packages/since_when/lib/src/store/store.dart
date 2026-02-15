// lib/src/store/store.dart

/// Barrel file for the data store abstraction layer.
///
/// Import this single file to access all store interfaces:
///
/// ```dart
/// import 'package:since_when/src/store/store.dart';
/// ```
///
/// Or import individual interfaces:
///
/// ```dart
/// import 'package:since_when/src/store/since_when_record_store.dart';
/// ```
library;


export 'since_when_data_store.dart';
export 'since_when_data_transfer_store.dart';
export 'since_when_record_store.dart';
export 'since_when_tag_store.dart';
