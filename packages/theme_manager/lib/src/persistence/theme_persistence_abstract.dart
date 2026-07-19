// theme_manager/lib/src/theme_persistence.dart
import 'dart:async' show FutureOr;
import 'package:flutter/material.dart';

/// Contract for persisting and restoring the user's [ThemeMode] selection.
///
/// Implementations abstract over the underlying storage mechanism so that
/// consumers (such as a theme cubit) can remain agnostic of whether the
/// choice is backed by shared preferences, a database, in-memory storage,
/// or a test double.
///
/// Both [load] and [save] return [FutureOr] to accommodate synchronous
/// backends (e.g. an already-initialized cache) as well as asynchronous
/// ones (e.g. a disk or network write).
abstract class ThemePersistenceAbstract {
  /// Returns the currently persisted [ThemeMode].
  ///
  /// Implementations should return a sensible default (such as
  /// [ThemeMode.dark] or [ThemeMode.system]) when no value has previously
  /// been stored or when the stored value cannot be parsed.
  FutureOr<ThemeMode> load();

  /// Persists [mode] as the user's current theme selection.
  ///
  /// Subsequent calls to [load] should return the most recently saved value.
  FutureOr<void> save(ThemeMode mode);
}
