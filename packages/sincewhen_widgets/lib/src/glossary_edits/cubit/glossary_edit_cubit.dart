// packages/sincewhen_widgets/lib/src/glossary_edits/cubit/glossary_edit_cubit.dart
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_color_generator/random_color_generator.dart'
    show RandomColorGenerator;
import 'package:sincewhen_models/sincewhen_models.dart'
    show GlossaryItem, GlossaryRepository;
import 'package:sincewhen_widgets/src/glossary_edits/cubit/glossary_edit_state.dart'
    show
        GlossaryEditColorList,
        GlossaryEditColorRequest,
        GlossaryEditInitial,
        GlossaryEditPopover,
        GlossaryEditState;

/// Cubit for handling database queries needed when doing CRUD on glossary
/// table of colors/tags
class GlossaryEditCubit extends Cubit<GlossaryEditState> {
  /// Constructor
  GlossaryEditCubit({
    required this._glossaryRepo,
    required this._uniqueTime,
    Color Function()? colorGenerator,
  }) : _generateColor = colorGenerator ?? RandomColorGenerator.generate,
       super(const GlossaryEditInitial());

  /// To keep items de-coupled a resolver (like get_it) is used to access the
  /// database DAOs.
  final GlossaryRepository _glossaryRepo;

  /// Function used to generate a random color.
  /// Defaults to [RandomColorGenerator.generate] if none is provided.
  final Color Function() _generateColor;

  final Future<DateTime> Function() _uniqueTime;

  /// Request a number of random colors
  Future<void> requestRandomColors({required int count}) async {
    emit(const GlossaryEditColorRequest());

    final Set<int> colorSet = await _glossaryRepo.allColorArgbValues();
    final List<Color> colorList = [];

    while (colorList.length < count) {
      // Use the injected function here
      final randomColor = _generateColor();

      if (!colorSet.contains(randomColor.toInt()) &&
          !colorList.contains(randomColor)) {
        colorList.add(randomColor);
      }
    }

    emit(GlossaryEditColorList(colorList));
  }

  /// If the user has selected a color then emit state where they can complete
  /// the content of the Glossary Edit
  Future<void> requestNewId({required int usingColor}) async {
    final int ts = (await _uniqueTime()).microsecondsSinceEpoch;
    emit(GlossaryEditPopover(usingColor, ts));
  }

  /// When the user completes (or cancels) the edit of GlossaryItem then the
  /// item is either placed into the database or not, and jumps back to the edit
  /// state.
  Future<void> editComplete({GlossaryItem? glossaryItem}) async {
    if (glossaryItem != null) {
      await _glossaryRepo.insertItem(glossaryItem);
      final c = await _glossaryRepo.itemCount();
    }
    emit(const GlossaryEditInitial());
  }
}
