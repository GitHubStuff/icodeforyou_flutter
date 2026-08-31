// packages/sincewhen_widgets/lib/src/glossary_edits/glossary_edit_page.dart

import 'package:dependency_resolver/dependency_resolver.dart'
    show DependencyResolver;
import 'package:extensions/datetime/src/datetime_ext.dart' show DateTimeExt;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sincewhen_models/sincewhen_models.dart' show GlossaryRepository;
import 'package:sincewhen_widgets/sincewhen_widgets.dart'
    show GlossaryEditCubit, GlossaryEditView;

/// {@template glossary_edit_page}
/// Page entry point for creating and editing glossary items.
///
/// Reads the [DependencyResolver] from the ancestor [RepositoryProvider]
/// to locate the [GlossaryRepository] contract, instantiates a
/// [GlossaryEditCubit], and renders the [GlossaryEditView].
/// {@endtemplate}
class GlossaryEditPage extends StatelessWidget {
  /// {@macro glossary_edit_page}
  const GlossaryEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the resolver from the inherited RepositoryProvider
    final resolver = context.read<DependencyResolver>();

    return BlocProvider(
      create: (context) => GlossaryEditCubit(
        // Resolve the repository contract lazily from DI
        glossaryRepo: resolver.get<GlossaryRepository>(),
        uniqueTime: DateTimeExt.unique,
      ),
      child: const GlossaryEditView(),
    );
  }
}
