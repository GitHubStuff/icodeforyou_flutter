// feeding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import '../../data/services/firestore_feeding_service.dart';
import '../../domain/entities/feeding_data.dart';
import 'feeding/cubit/feeding_cubit.dart';
import 'feeding/cubit/feeding_state.dart';

/// Feeding tracker screen
/// Single Responsibility: Coordinate feeding display and updates
class FeedingScreen extends StatelessWidget {
  const FeedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          FeedingCubit(repository: FirestoreFeedingService())..watchFeeding(),
      child: const _FeedingView(),
    );
  }
}

/// Main view for feeding screen
class _FeedingView extends StatelessWidget {
  static const double _padding = 24.0;
  static const String _title = 'Dog Feeding Tracker';

  const _FeedingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: Padding(
        padding: const EdgeInsets.all(_padding),
        child: const _FeedingBody(),
      ),
    );
  }
}

/// Body content that responds to state
class _FeedingBody extends StatelessWidget {
  const _FeedingBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedingCubit, FeedingState>(
      builder: (context, state) {
        if (state is FeedingLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FeedingLoaded) {
          return _FeedingData(data: state.data);
        }
        if (state is FeedingEmpty) {
          return const _NoData();
        }
        if (state is FeedingError) {
          return _ErrorDisplay(message: state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Display when feeding data exists
class _FeedingData extends StatelessWidget {
  static const double _iconSize = 80.0;
  static const double _spacing = 32.0;
  static const double _textSpacing = 16.0;
  static const double _fontSize = 18.0;
  static const double _titleSize = 24.0;
  static const String _lastFedLabel = 'Last fed by:';

  final FeedingData data;

  const _FeedingData({required this.data});

  String _formatTime() {
    final fed = DateTime.fromMillisecondsSinceEpoch(data.epoc);
    final diff = DateTime.now().difference(fed);

    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.pets, size: _iconSize, color: Colors.green),
        const Gap(_spacing),
        Text(
          _lastFedLabel,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _fontSize, color: Colors.grey[600]),
        ),
        const Gap(_textSpacing),
        Text(
          data.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: _titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(_textSpacing),
        Text(
          _formatTime(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _fontSize, color: Colors.grey[600]),
        ),
        const Gap(_spacing),
        const _FeedButton(),
      ],
    );
  }
}

/// Display when no data
class _NoData extends StatelessWidget {
  static const double _iconSize = 80.0;
  static const double _spacing = 32.0;
  static const double _textSpacing = 16.0;
  static const double _fontSize = 18.0;
  static const double _titleSize = 24.0;
  static const String _title = 'No feeding data yet';
  static const String _subtitle = 'Tap below to record first feeding';

  const _NoData();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.pets, size: _iconSize, color: Colors.orange),
        const Gap(_spacing),
        const Text(
          _title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _titleSize, fontWeight: FontWeight.bold),
        ),
        const Gap(_textSpacing),
        Text(
          _subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _fontSize, color: Colors.grey[600]),
        ),
        const Gap(_spacing),
        const _FeedButton(),
      ],
    );
  }
}

/// Error display
class _ErrorDisplay extends StatelessWidget {
  static const double _iconSize = 80.0;
  static const double _spacing = 32.0;
  static const double _textSpacing = 16.0;
  static const double _fontSize = 18.0;
  static const double _titleSize = 24.0;
  static const String _title = 'Error loading data';
  static const String _buttonText = 'Retry';

  final String message;

  const _ErrorDisplay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.error_outline, size: _iconSize, color: Colors.red),
        const Gap(_spacing),
        const Text(
          _title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _titleSize, fontWeight: FontWeight.bold),
        ),
        const Gap(_textSpacing),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: _fontSize, color: Colors.grey[600]),
        ),
        const Gap(_spacing),
        ElevatedButton(
          onPressed: () => context.read<FeedingCubit>().loadFeeding(),
          child: const Text(_buttonText),
        ),
      ],
    );
  }
}

/// Feed button widget
class _FeedButton extends StatelessWidget {
  static const double _height = 56.0;
  static const double _fontSize = 18.0;
  static const String _text = 'I Fed the Dog';

  const _FeedButton();

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    final email = user?.email;
    return email?.split('@').first ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: ElevatedButton.icon(
        onPressed: () {
          final name = _getUserName();
          context.read<FeedingCubit>().updateFeeding(name);
        },
        icon: const Icon(Icons.restaurant),
        label: const Text(_text, style: TextStyle(fontSize: _fontSize)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
