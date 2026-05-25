// packages/since_when_framework/lib/database.dart

/// Generic SQLite lifecycle scaffold: configuration, handle, lifecycle cubit,
/// pluggable setup / importer / exporter interfaces, sealed failure hierarchy.
library;

export 'src/database/configuration/database_access.dart';
export 'src/database/configuration/database_configuration.dart';
export 'src/database/failure/database_failure.dart';
export 'src/database/handle/database_handle.dart';
export 'src/database/handle/sqflite_handle.dart';
export 'src/database/io/database_exporter.dart';
export 'src/database/io/database_importer.dart';
export 'src/database/lifecycle/database_lifecycle_cubit.dart';
export 'src/database/lifecycle/database_lifecycle_state.dart';
export 'src/database/setup/database_setup.dart';
