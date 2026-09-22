// packages/sincewhen_screens/lib/src/cubit/cubit.dart

import 'dart:async';

import 'package:extensions/extensions.dart' show DateTimeExt;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show SinceWhenItem;
import 'package:sincewhen_screens/src/cubit/state.dart'
    show
        SinceWhenMiniAction,
        SinceWhenMiniLoading,
        SinceWhenMiniReady,
        SinceWhenMiniState;

/// {@template since_when_mini_cubit}
/// Business rules for the since-when-mini create/edit screen.
///
/// **Create mode** (`item == null`): starts in [SinceWhenMiniLoading],
/// mints one unique timestamp, and emits a [SinceWhenMiniReady] whose
/// `created`, `reviewed`, and `edited` stamps all carry that value — a
/// created record *is* its creation.
///
/// **Edit mode** (`item != null`): starts directly in
/// [SinceWhenMiniReady] with the record's own values as the draft and
/// the record itself as the dirty-check baseline.
///
/// Exit stamping happens in [complete], driven by the derived
/// [SinceWhenMiniAction]:
///
/// * `submit` — creation stamps pass through unchanged.
/// * `update` — one fresh stamp is applied to both `reviewed` and
///   `edited` (an edit implies a review).
/// * `reviewed` — a fresh stamp is applied to `reviewed` only.
///
/// [now] is the clock used for minting; inject a fake in tests.
/// {@endtemplate}
class SinceWhenMiniCubit extends Cubit<SinceWhenMiniState> {
  /// {@macro since_when_mini_cubit}
  SinceWhenMiniCubit({
    SinceWhenItem? item,
    this._now = DateTime.now,
  }) : super(_initialState(item)) {
    if (item == null) {
      unawaited(_mintCreateDraft());
    }
  }

  final DateTime Function() _now;

  /// Synchronous initial state: [SinceWhenMiniReady] for an existing
  /// record, [SinceWhenMiniLoading] while a new record's stamps are
  /// minted.
  static SinceWhenMiniState _initialState(SinceWhenItem? item) {
    if (item == null) {
      return const SinceWhenMiniLoading();
    }
    return SinceWhenMiniReady(
      original: item,
      createdTimestamp: item.createdTimestamp,
      reviewedTimestamp: item.reviewedTimestamp,
      editedTimestamp: item.editedTimestamp,
      content: item.content,
      metaData: item.metaData ?? '',
      tldr: item.tldr ?? '',
      eventTimestamp: item.eventTimestamp,
    );
  }

  /// Mints the create-mode stamps and promotes the state to
  /// [SinceWhenMiniReady].
  Future<void> _mintCreateDraft() async {
    final minted = await DateTimeExt.unique(now: _now);
    if (isClosed) {
      return;
    }
    final stamp = minted.microsecondsSinceEpoch;
    emit(
      SinceWhenMiniReady(
        createdTimestamp: stamp,
        reviewedTimestamp: stamp,
        editedTimestamp: stamp,
        content: '',
        metaData: '',
        tldr: '',
      ),
    );
  }

  /// Applies [change] to the current draft; ignored while loading.
  void _mutate(
    SinceWhenMiniReady Function(SinceWhenMiniReady ready) change,
  ) {
    final current = state;
    if (current is SinceWhenMiniReady) {
      emit(change(current));
    }
  }

  /// Records the latest `content` text.
  void contentChanged(String content) =>
      _mutate((ready) => ready.copyWith(content: content));

  /// Records the latest `metaData` text.
  void metaDataChanged(String metaData) =>
      _mutate((ready) => ready.copyWith(metaData: metaData));

  /// Records the latest `tldr` text.
  void tldrChanged(String tldr) =>
      _mutate((ready) => ready.copyWith(tldr: tldr));

  /// Records a newly picked event date/time.
  void eventTimestampChanged(DateTime eventDateTime) => _mutate(
    (ready) => ready.copyWith(
      eventTimestamp: eventDateTime.microsecondsSinceEpoch,
    ),
  );

  /// Clears the event date/time (the ✕ affordance).
  ///
  /// Clearing is an ordinary field change: in edit mode it participates
  /// in the dirty check like any other edit.
  void eventTimestampCleared() =>
      _mutate((ready) => ready.copyWith(eventTimestamp: null));

  /// Builds the record for the primary-button exit.
  ///
  /// Stamps according to the current [SinceWhenMiniAction] (see class
  /// docs) and returns the record for the caller to pop. Does not emit:
  /// exit stamping is a terminal computation, not a state transition.
  ///
  /// Throws [StateError] if called before the draft is ready; the UI
  /// must not enable the primary button in [SinceWhenMiniLoading].
  Future<SinceWhenItem> complete() async {
    final current = state;
    if (current is! SinceWhenMiniReady) {
      throw StateError('complete() called before draft was ready');
    }
    switch (current.primaryAction) {
      case SinceWhenMiniAction.submit:
        return current.toItem(
          reviewedTimestamp: current.reviewedTimestamp,
          editedTimestamp: current.editedTimestamp,
        );
      case SinceWhenMiniAction.update:
        final stamp = await _mint();
        return current.toItem(
          reviewedTimestamp: stamp,
          editedTimestamp: stamp,
        );
      case SinceWhenMiniAction.reviewed:
        final stamp = await _mint();
        return current.toItem(
          reviewedTimestamp: stamp,
          editedTimestamp: current.editedTimestamp,
        );
    }
  }

  /// Mints one unique timestamp in microseconds since epoch.
  Future<int> _mint() async {
    final minted = await DateTimeExt.unique(now: _now);
    return minted.microsecondsSinceEpoch;
  }
}
