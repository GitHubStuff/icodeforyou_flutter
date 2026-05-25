// packages/ice_chips_tray/widgetbook/usecases/ice_picker_tray.usecase.dart
// ignore_for_file: comment_references, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ice_chips/ice_chips.dart'
    show
        IceChipsTrayCubit,
        IceChipsTrayLayoutWrap,
        IcePickerTray,
        RecordTagDefinition,
        SinceWhenFailure,
        TagsCubit,
        TagsError,
        TagsInitial,
        TagsLoaded,
        TagsLoading,
        TagsState;
import 'package:since_when_framework/database.dart' show DatabaseOpenFailure;
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: IcePickerTray,
)
Widget buildIcePickerTrayUseCase(BuildContext context) {
  final state = context.knobs.object.dropdown<TagsState>(
    label: 'state',
    options: [
      const TagsInitial(),
      const TagsLoading(),
      _loadedSample,
      _errorSample,
    ],
    initialOption: _loadedSample,
    labelBuilder: _stateLabel,
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<TagsCubit>(create: (_) => _FakeTagsCubit(state)),
      BlocProvider<IceChipsTrayCubit>(create: (_) => IceChipsTrayCubit()),
    ],
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: IcePickerTray(layout: IceChipsTrayLayoutWrap()),
    ),
  );
}

String _stateLabel(TagsState state) => switch (state) {
  TagsInitial() => 'Initial',
  TagsLoading() => 'Loading',
  TagsLoaded() => 'Loaded',
  TagsError() => 'Error',
};

final TagsLoaded _loadedSample = TagsLoaded([
  RecordTagDefinition(
    id: 1,
    createdTimeStamp: 1700000001000,
    tagName: 'Coffee',
    color: Colors.brown.toARGB32(),
  ),
  RecordTagDefinition(
    id: 2,
    createdTimeStamp: 1700000002000,
    tagName: 'Tea',
    color: Colors.green.toARGB32(),
  ),
  RecordTagDefinition(
    id: 3,
    createdTimeStamp: 1700000003000,
    tagName: 'Water',
    color: Colors.blue.toARGB32(),
  ),
  RecordTagDefinition(
    id: 4,
    createdTimeStamp: 1700000004000,
    tagName: 'Juice',
    color: Colors.orange.toARGB32(),
  ),
]);

final TagsError _errorSample = TagsError(
  SinceWhenFailure(DatabaseOpenFailure(Exception('Failed to load tags'))),
);

/// Fake [TagsCubit] for Widgetbook — emits a fixed [TagsState] without
/// touching a real database. Mutations are no-ops.
class _FakeTagsCubit extends Cubit<TagsState> implements TagsCubit {
  _FakeTagsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> add({required String tagName, required int color}) async {}

  @override
  Future<void> update(RecordTagDefinition tag) async {}

  @override
  Future<void> remove(int id) async {}
}
