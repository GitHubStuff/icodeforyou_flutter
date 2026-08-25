import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sincewhen_models/sincewhen_models.dart';
import 'package:sincewhen_widgets/sincewhen_widgets.dart';

class GlossaryEditPage extends StatelessWidget {
  const GlossaryEditPage({
    required this.glossaryRepository,
    super.key,
  });

  /// Resolved from your DI container (e.g. DependencyResolver) at the route/page level.
  final GlossaryRepository glossaryRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GlossaryEditCubit(
        glossaryRepo: glossaryRepository,
      ),
      child: const GlossaryEditView(),
    );
  }
}

class GlossaryEditView extends StatelessWidget {
  const GlossaryEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Glossary')),
      body: BlocBuilder<GlossaryEditCubit, GlossaryEditState>(
        builder: (context, state) {
          debugPrint('State: $state');
          // Read state or trigger cubit actions via context
          final cubit = context.read<GlossaryEditCubit>();

          return Center(
            child: ElevatedButton(
              onPressed: () => cubit.requestRandomColors(count: 15),
              child: const Text('Refresh Used Colors'),
            ),
          );
        },
      ),
    );
  }
}
