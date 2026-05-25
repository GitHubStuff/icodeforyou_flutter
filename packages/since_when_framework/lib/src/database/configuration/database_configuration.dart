// packages/since_when_framework/lib/src/database/configuration/database_configuration.dart

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:since_when_framework/src/database/configuration/database_access.dart';

/// Where the database lives, what it is called, and how it should be opened.
///
/// Write-once / use-everywhere: a single configuration value carries every
/// piece of information the framework needs to resolve a path, open the
/// connection, and delete the on-device file.
///
/// Sealed so adding a new variant (background-isolate, network-backed, etc.)
/// is a compile-time obligation on every `switch` that handles it.
sealed class DatabaseConfiguration extends Equatable {
  const DatabaseConfiguration();

  /// File-backed database under the platform's application **documents**
  /// directory (`path_provider.getApplicationDocumentsDirectory`).
  const factory DatabaseConfiguration.documents({
    required String dbName,
    String subdirectory,
    DatabaseAccess access,
  }) = DatabaseConfigurationDocuments;

  /// File-backed database under the platform's **application support**
  /// directory (`path_provider.getApplicationSupportDirectory`).
  const factory DatabaseConfiguration.applicationSupport({
    required String dbName,
    String subdirectory,
    DatabaseAccess access,
  }) = DatabaseConfigurationApplicationSupport;

  /// In-memory database. Intended for tests and the sqlite_viewer workflow.
  const factory DatabaseConfiguration.inMemory() =
      DatabaseConfigurationInMemory;

  /// Resolve the full filesystem path for this configuration.
  ///
  /// For in-memory configurations this returns sqflite's `:memory:` sentinel.
  Future<String> resolvePath();

  /// Whether this configuration is backed by an on-disk file.
  bool get isFileBacked;
}

// ─── Documents directory ─────────────────────────────────────────────────────

/// Documents-directory backed configuration.
final class DatabaseConfigurationDocuments extends DatabaseConfiguration {
  const DatabaseConfigurationDocuments({
    required this.dbName,
    this.subdirectory = 'db',
    this.access = DatabaseAccess.automatic,
  });

  final String dbName;
  final String subdirectory;
  final DatabaseAccess access;

  @override
  bool get isFileBacked => true;

  @override
  Future<String> resolvePath() async {
    final root = await getApplicationDocumentsDirectory();
    return _composePath(root.path, subdirectory, dbName);
  }

  @override
  List<Object?> get props => [dbName, subdirectory, access];
}

// ─── Application-support directory ───────────────────────────────────────────

/// Application-support-directory backed configuration.
final class DatabaseConfigurationApplicationSupport
    extends DatabaseConfiguration {
  const DatabaseConfigurationApplicationSupport({
    required this.dbName,
    this.subdirectory = 'db',
    this.access = DatabaseAccess.automatic,
  });

  final String dbName;
  final String subdirectory;
  final DatabaseAccess access;

  @override
  bool get isFileBacked => true;

  @override
  Future<String> resolvePath() async {
    final root = await getApplicationSupportDirectory();
    return _composePath(root.path, subdirectory, dbName);
  }

  @override
  List<Object?> get props => [dbName, subdirectory, access];
}

// ─── In-memory ───────────────────────────────────────────────────────────────

/// In-memory configuration.
final class DatabaseConfigurationInMemory extends DatabaseConfiguration {
  const DatabaseConfigurationInMemory();

  @override
  bool get isFileBacked => false;

  @override
  Future<String> resolvePath() async => ':memory:';

  @override
  List<Object?> get props => const [];
}

// ─── Shared path composition ─────────────────────────────────────────────────

String _composePath(String root, String subdirectory, String dbName) {
  final normalized = _stripSlashes(subdirectory.trim());
  final directory = normalized.isEmpty ? root : p.join(root, normalized);
  return p.join(directory, dbName.trim());
}

String _stripSlashes(String path) {
  var normalized = path;
  while (normalized.startsWith('/') || normalized.startsWith(r'\')) {
    normalized = normalized.substring(1);
  }
  while (normalized.endsWith('/') || normalized.endsWith(r'\')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
