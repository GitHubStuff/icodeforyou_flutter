// startup_demo/lib/src/pages/database_page.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:since_when_framework/database.dart'
    show
        DatabaseClosed,
        DatabaseConfiguration,
        DatabaseFailed,
        DatabaseLifecycleCubit,
        DatabaseLifecycleState,
        DatabaseReady;
import 'package:startup_demo/src/pages/database_pages/viewer.dart';

/// Root of the database flow.
///
/// Single responsibility: create an in-memory database. One button,
/// one state badge. When the lifecycle reaches [DatabaseReady], a
/// floating action button reveals the viewer route.
///
/// Provides a [DatabaseLifecycleCubit] scoped to this subtree so the
/// viewer route (pushed by the FAB) can read the same instance via
/// [BlocProvider.value].
class DatabasePage extends StatelessWidget {
  const DatabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DatabaseLifecycleCubit>(
      create: (_) => DatabaseLifecycleCubit(),
      child: const _DatabasePageView(),
    );
  }
}

class _DatabasePageView extends StatelessWidget {
  const _DatabasePageView();

  Future<void> _create(BuildContext context) {
    return context.read<DatabaseLifecycleCubit>().open(
          configuration: const DatabaseConfiguration.inMemory(),
        );
  }

  void _openViewer(BuildContext context) {
    final cubit = context.read<DatabaseLifecycleCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<DatabaseLifecycleCubit>.value(
          value: cubit,
          child: const DatabaseViewerPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database')),
      body: BlocBuilder<DatabaseLifecycleCubit, DatabaseLifecycleState>(
        builder: (context, state) {
          final canCreate = state is DatabaseClosed || state is DatabaseFailed;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: canCreate ? () => _create(context) : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Create in-memory database'),
                ),
                const SizedBox(height: 16),
                _StateBadge(state: state),
              ],
            ),
          );
        },
      ),
      floatingActionButton:
          BlocBuilder<DatabaseLifecycleCubit, DatabaseLifecycleState>(
        builder: (context, state) {
          if (state is! DatabaseReady) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _openViewer(context),
            icon: const Icon(Icons.table_view),
            label: const Text('Query'),
          );
        },
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});

  final DatabaseLifecycleState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          state.runtimeType.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
