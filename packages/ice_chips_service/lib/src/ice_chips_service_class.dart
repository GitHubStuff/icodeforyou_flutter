// packages/ice_chips_service/lib/src/ice_chips_service_class.dart

import 'package:ice_chips/ice_chips.dart' show TagsCubit;
import 'package:service_locator/service_locator.dart' show ServiceClass;

/// Service-locator handle exposing a [TagsCubit] backed by the
/// `SinceWhen` service's database.
///
/// The cubit is constructed once during service startup and has its
/// initial `TagsCubit.load` completed before this service is marked
/// ready. Consumers retrieve it via the locator and wire it into
/// widget trees with `BlocProvider.value`.
class IceChipsServiceClass implements ServiceClass {
  /// Wraps an already-loaded [TagsCubit].
  const IceChipsServiceClass(this.tagsCubit);

  /// The loaded glossary cubit, ready to provide above an
  /// `IcePickerTray`.
  final TagsCubit tagsCubit;
}
