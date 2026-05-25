// packages/ice_chips/lib/ice_chips.dart

// ─────────────────────────────────────────────────────────────────────────────
// TODO(since_when): drop the `glossary_types_todo.dart` export the day the
// real `since_when` package ships. Consumers should import the real
// repository interfaces and row model directly from `since_when`, not
// through this barrel.
// ─────────────────────────────────────────────────────────────────────────────
export 'src/glossary_types_todo.dart'
    show
        GlossaryDeleter,
        GlossaryReader,
        GlossaryRepository,
        GlossaryWriter,
        RecordTagDefinition,
        SinceWhenFailure;

export 'src/ice_chip_tray/ice_chip_tray.dart';
export 'src/ice_chip_tray/ice_chip_tray_cubit.dart';
export 'src/ice_chip_tray/ice_chip_tray_layout.dart';
export 'src/ice_chip_tray/ice_picker_tray.dart';
export 'src/ice_chip_widget/ice_chip.dart';
export 'src/ice_chip_widget/ice_chip_data.dart';
export 'src/tags/tags_cubit.dart';
export 'src/tags/tags_state.dart';
