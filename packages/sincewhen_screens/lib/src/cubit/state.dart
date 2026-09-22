// packages/sincewhen_screens/lib/src/cubit/state.dart

import 'package:equatable/equatable.dart';
import 'package:sincewhen_models/sincewhen_models.dart';

/// Returns `null` when [raw] contains no visible characters, otherwise
/// returns [raw] unchanged.
///
/// Used to normalize the optional text columns (`metaData`, `tldr`) so the
/// database carries exactly one representation of absence: `null`, never
/// the empty (or whitespace-only) string.
String? _normalized(String raw) => raw.trim().isEmpty ? null : raw;

/// The action presented by the primary button of the since-when-mini
/// screen.
///
/// Which action applies is derived, never chosen by the user:
///
/// * [submit] — create mode (no record was passed in).
/// * [update] — edit mode with at least one changed field.
/// * [reviewed] — edit mode with no changed fields.
enum SinceWhenMiniAction {
  /// Create mode: pop a brand-new record.
  submit('Submit'),

  /// Edit mode with changes: stamp edited and reviewed, then pop.
  update('Update'),

  /// Edit mode without changes: stamp reviewed only, then pop.
  reviewed('Reviewed');

  const SinceWhenMiniAction(this.label);

  /// The label displayed on the primary button.
  final String label;
}

/// {@template since_when_mini_state}
/// State family for the since-when-mini edit/create screen.
///
/// [SinceWhenMiniLoading] is emitted while create-mode timestamps are
/// being minted (minting is asynchronous). [SinceWhenMiniReady] carries
/// the editable draft and everything derived from it.
/// {@endtemplate}
sealed class SinceWhenMiniState extends Equatable {
  /// {@macro since_when_mini_state}
  const SinceWhenMiniState();
}

/// {@template since_when_mini_loading}
/// Transient state while the create-mode timestamps are minted.
///
/// Never emitted in edit mode: an existing record's timestamps are copied
/// synchronously.
/// {@endtemplate}
final class SinceWhenMiniLoading extends SinceWhenMiniState {
  /// {@macro since_when_mini_loading}
  const SinceWhenMiniLoading();

  @override
  List<Object?> get props => const [];
}

/// {@template since_when_mini_ready}
/// The editable draft of a since-when record plus derived view state.
///
/// [original] is `null` in create mode. In edit mode it is the record as
/// passed in, and is the baseline every dirty-check compares against.
///
/// The three stamp fields are fixed for the lifetime of the screen: in
/// create mode all three hold the same freshly minted value; in edit
/// mode they are copies from [original]. Fresh `reviewed`/`edited`
/// stamps are applied only when the record is popped, via [toItem].
/// {@endtemplate}
final class SinceWhenMiniReady extends SinceWhenMiniState {
  /// {@macro since_when_mini_ready}
  const SinceWhenMiniReady({
    required this.createdTimestamp,
    required this.reviewedTimestamp,
    required this.editedTimestamp,
    required this.content,
    required this.metaData,
    required this.tldr,
    this.original,
    this.eventTimestamp,
  });

  /// The record being edited, or `null` when creating a new record.
  final SinceWhenItem? original;

  /// Microseconds since epoch; immutable identity of the record.
  final int createdTimestamp;

  /// Microseconds since epoch; the last-reviewed stamp as displayed.
  final int reviewedTimestamp;

  /// Microseconds since epoch; the last-edited stamp as displayed.
  final int editedTimestamp;

  /// The content text exactly as typed.
  final String content;

  /// The metadata text exactly as typed; normalized on pop.
  final String metaData;

  /// The tldr text exactly as typed; normalized on pop.
  final String tldr;

  /// Microseconds since epoch of the described event, or `null`.
  final int? eventTimestamp;

  static const Object _unset = Object();

  /// Whether this screen is creating a new record.
  bool get isCreate => original == null;

  /// The sibling-ordering value; read-only in this release.
  int get sequenceNumber => original?.sequenceNumber ?? 0;

  /// [metaData] normalized: `null` when it has no visible characters.
  String? get normalizedMetaData => _normalized(metaData);

  /// [tldr] normalized: `null` when it has no visible characters.
  String? get normalizedTldr => _normalized(tldr);

  /// Whether [content] contains at least one visible character.
  bool get hasContent => content.trim().isNotEmpty;

  /// Whether any editable field differs from [original].
  ///
  /// Always `false` in create mode: a new record has no baseline to
  /// differ from, and its stamps already reflect its creation.
  bool get isDirty {
    final base = original;
    if (base == null) {
      return false;
    }
    return content != base.content ||
        normalizedMetaData != base.metaData ||
        normalizedTldr != base.tldr ||
        eventTimestamp != base.eventTimestamp;
  }

  /// The action the primary button performs in this state.
  SinceWhenMiniAction get primaryAction {
    if (isCreate) {
      return SinceWhenMiniAction.submit;
    }
    return isDirty ? SinceWhenMiniAction.update : SinceWhenMiniAction.reviewed;
  }

  /// Whether the primary button is enabled.
  ///
  /// [SinceWhenMiniAction.reviewed] is always enabled — nothing changed,
  /// so the record is as valid as it was when passed in. The other two
  /// actions require [hasContent].
  bool get isPrimaryEnabled =>
      primaryAction == SinceWhenMiniAction.reviewed || hasContent;

  /// Builds the record to pop, applying the supplied stamps.
  ///
  /// The cubit supplies [reviewedTimestamp] and [editedTimestamp]
  /// according to the exit action:
  ///
  /// * submit — both are this state's (creation) stamps, unchanged.
  /// * update — both carry one freshly minted value.
  /// * reviewed — a fresh reviewed stamp; edited is unchanged.
  ///
  /// `id` is `0` for an unpersisted record; `parentTimestamp` is
  /// preserved from [original] and is `null` for new records.
  SinceWhenItem toItem({
    required int reviewedTimestamp,
    required int editedTimestamp,
  }) {
    return SinceWhenItem(
      id: original?.id ?? 0,
      createdTimestamp: createdTimestamp,
      reviewedTimestamp: reviewedTimestamp,
      editedTimestamp: editedTimestamp,
      sequenceNumber: sequenceNumber,
      content: content,
      parentTimestamp: original?.parentTimestamp,
      eventTimestamp: eventTimestamp,
      metaData: normalizedMetaData,
      tldr: normalizedTldr,
    );
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// [eventTimestamp] uses a sentinel default so callers can clear it to
  /// `null` (the clear affordance) as distinct from leaving it unchanged.
  SinceWhenMiniReady copyWith({
    String? content,
    String? metaData,
    String? tldr,
    Object? eventTimestamp = _unset,
  }) {
    return SinceWhenMiniReady(
      original: original,
      createdTimestamp: createdTimestamp,
      reviewedTimestamp: reviewedTimestamp,
      editedTimestamp: editedTimestamp,
      content: content ?? this.content,
      metaData: metaData ?? this.metaData,
      tldr: tldr ?? this.tldr,
      eventTimestamp: eventTimestamp == _unset
          ? this.eventTimestamp
          : eventTimestamp as int?,
    );
  }

  @override
  List<Object?> get props => [
    original,
    createdTimestamp,
    reviewedTimestamp,
    editedTimestamp,
    content,
    metaData,
    tldr,
    eventTimestamp,
  ];
}
