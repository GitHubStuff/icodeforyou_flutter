// programs/since_when_dev/lib/app/since_when_configurations.dart

import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart'
    show
        SinceWhenAppFolderConfiguration,
        SinceWhenDocumentsConfiguration,
        SinceWhenInMemoryConfiguration;

/// Program-specific since_when database configurations.
///
/// Pure data: where the development database lives. Startup logic is
/// `SinceWhenStartup` in `sincewhen_drift_framework`; `main` passes one
/// of these configurations to it.
abstract final class SinceWhenDevConfigurations {
  /// Persisted development database in the documents folder.
  static const documents = SinceWhenDocumentsConfiguration(
    fileName: 'since_when_dev',
  );

  /// Persisted development database in the application support folder.
  static const appFolder = SinceWhenAppFolderConfiguration(
    fileName: 'since_when_dev',
  );

  /// Ephemeral database for development runs.
  static const inMemory = SinceWhenInMemoryConfiguration();
}
