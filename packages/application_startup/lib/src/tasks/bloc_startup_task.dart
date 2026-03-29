// application_startup/lib/src/app/bloc_startup_task.dart
import 'package:application_startup/src/tasks/startup_task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [StartupTask] that owns a [BlocBase] instance and exposes it
/// as a [BlocProvider] for injection into the widget tree.
///
/// Extend this class for any startup task that needs to register
/// a cubit or bloc during application initialisation.
abstract class BlocStartupTask<T extends BlocBase<Object?>>
    extends StartupTask {
  // coverage:ignore-line
  // ignore: public_member_api_docs
  const BlocStartupTask();

  /// The [BlocBase] instance managed by this startup task.
  T get bloc;

  /// Returns a [BlocProvider] wrapping [bloc] for widget tree injection.
  @override
  BlocProvider<T> get blocProvider => BlocProvider<T>.value(value: bloc);
}
