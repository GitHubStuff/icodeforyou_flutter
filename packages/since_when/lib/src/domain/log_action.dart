// lib/src/domain/log_action.dart

/// The action recorded in the [since_when_log] audit table.
///
/// Open for extension — new values may be added as operations grow.
enum LogAction { create, read, update, delete }
