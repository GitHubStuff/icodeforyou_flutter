// packages/sincewhen_widgets/lib/src/glossary_edits/glossary_edit_cubit.dart
import 'package:extensions/extensions.dart' show ColorExt;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_color_generator/random_color_generator.dart'
    show RandomColorGenerator;
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryRepository;
import 'package:sincewhen_widgets/src/glossary_edits/glossary_edit_state.dart'
    show
        GlossaryEditColorList,
        GlossaryEditColorRequest,
        GlossaryEditInitial,
        GlossaryEditState;

/// Cubit for handling database queries needed when doing CRUD on glossary
/// table of colors/tags
class GlossaryEditCubit extends Cubit<GlossaryEditState> {
  /// Constructor
  GlossaryEditCubit({
    required this._glossaryRepo,
    Color Function()? colorGenerator,
  }) : _generateColor = colorGenerator ?? RandomColorGenerator.generate,
       super(const GlossaryEditInitial());

  /// To keep items de-coupled a resolver (like get_it) is used to access the
  /// database DAOs.
  final GlossaryRepository _glossaryRepo;

  /// Function used to generate a random color.
  /// Defaults to [RandomColorGenerator.generate] if none is provided.
  final Color Function() _generateColor;

  /// Request a number of random colors
  Future<void> requestRandomColors({required int count}) async {
    emit(const GlossaryEditColorRequest());

    final colorSet = await _glossaryRepo.allColorArgbValues();
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
}
