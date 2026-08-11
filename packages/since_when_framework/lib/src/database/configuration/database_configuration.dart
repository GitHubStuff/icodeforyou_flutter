// packages/since_when_framework/lib/src/database/configuration/database_configuration.dart

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:since_when_framework/src/database/configuration/database_access.dart';

/// {@template database_configuration.dart}
/// Where the database lives, what it is called, and how it should be opened.
///
/// Write-once / use-everywhere: a single configuration value carries every
/// piece of information the framework needs to resolve a path, open the
/// connection, and delete the on-device file.
///
/// Sealed so adding a new variant (background-isolate, network-backed, etc.)
/// is a compile-time obligation on every `switch` that handles it.
/// {@endtemplate}
sealed class DatabaseConfiguration extends Equatable {
  /// {@macro database_configuration.dart}
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

/// {@template database_configuration_documents}
/// Documents-directory backed configuration.
///
/// Resolves under `path_provider.getApplicationDocumentsDirectory` — the
/// user-visible location. Prefer [DatabaseConfigurationApplicationSupport]
/// for data the user should not browse or sync.
/// {@endtemplate}
final class DatabaseConfigurationDocuments extends DatabaseConfiguration {
  /// {@macro database_configuration_documents}
  const DatabaseConfigurationDocuments({
    required this.dbName,
    this.subdirectory = 'db',
    this.access = DatabaseAccess.automatic,
  });

  /// {@template database_configuration.dbName}
  /// File name of the database, including any extension (e.g. `notes.db`).
  /// Surrounding whitespace is trimmed during path resolution.
  /// {@endtemplate}
  final String dbName;

  /// {@template database_configuration.subdirectory}
  /// Subdirectory below the platform root under which the file lives.
  /// Leading/trailing slashes and surrounding whitespace are stripped during
  /// path resolution; an empty value places the file directly in the root.
  /// Defaults to `'db'`.
  /// {@endtemplate}
  final String subdirectory;

  /// {@template database_configuration.access}
  /// How opening behaves relative to the file's existence — see
  /// [DatabaseAccess]. Defaults to [DatabaseAccess.automatic].
  /// {@endtemplate}
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

/// {@template database_configuration_application_support}
/// Application-support-directory backed configuration.
///
/// Resolves under `path_provider.getApplicationSupportDirectory` — hidden
/// from the user and excluded from user-facing file browsing. The right
/// home for framework-managed data.
/// {@endtemplate}
final class DatabaseConfigurationApplicationSupport
    extends DatabaseConfiguration {
  /// {@macro database_configuration_application_support}
  const DatabaseConfigurationApplicationSupport({
    required this.dbName,
    this.subdirectory = 'db',
    this.access = DatabaseAccess.automatic,
  });

  /// {@macro database_configuration.dbName}
  final String dbName;

  /// {@macro database_configuration.subdirectory}
  final String subdirectory;

  /// {@macro database_configuration.access}
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

/// {@template database_configuration_in_memory}
/// In-memory configuration.
///
/// [resolvePath] yields sqflite's `:memory:` sentinel; nothing touches disk,
/// so [isFileBacked] is `false`. Intended for tests and the sqlite_viewer
/// workflow.
/// {@endtemplate}
final class DatabaseConfigurationInMemory extends DatabaseConfiguration {
  /// {@macro database_configuration_in_memory}
  const DatabaseConfigurationInMemory();

  @override
  bool get isFileBacked => false;

  @override
  Future<String> resolvePath() async => ':memory:';

  @override
  List<Object?> get props => const [];
}

// ─── Shared path composition ─────────────────────────────────────────────────

/// Joins [root], a sanitized [subdirectory], and a trimmed [dbName] into a
/// platform-correct path via `package:path`.
///
/// An empty (post-sanitization) [subdirectory] places [dbName] directly
/// under [root].
String _composePath(String root, String subdirectory, String dbName) {
  final normalized = _stripSlashes(subdirectory.trim());
  final directory = normalized.isEmpty ? root : p.join(root, normalized);
  return p.join(directory, dbName.trim());
}

/// Removes all leading and trailing `/` and `\` characters from [path].
///
/// Prevents a caller-supplied subdirectory like `'/db/'` from producing an
/// absolute path or a double separator when joined.
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
