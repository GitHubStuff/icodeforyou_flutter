// programs/creature_comfort/lib/src/screens/subscriptions_page.dart
// ignore_for_file: public_member_api_docs

import 'dart:async' show unawaited;

import 'package:creature_comfort/src/firebase/cubit/updater_cubit.dart'
    show UpdaterCubit;
import 'package:creature_comfort/src/firebase/cubit/updater_state.dart'
    show UpdaterError, UpdaterInitial, UpdaterReceived, UpdaterState;
import 'package:creature_comfort/src/firebase/updater_crud.dart'
    show UpdaterCrud;
import 'package:creature_comfort/src/typedef.dart' show defStyle;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart' show Gap;

// ---------------------------------------------------------------------------
// Tunables — single place to tweak this dev page.
// ---------------------------------------------------------------------------

// Layout.
const double _kPagePadding = 16;
const double _kTitleGap = 16;
const double _kButtonSpacing = 12;
const double _kStatusGap = 24;
const double _kDetailGap = 8;

// Colors.
const Color _kErrorColor = Colors.red;
const Color _kSubscribedColor = Colors.green;

// Labels.
const String _kTitle = 'Subscriptions';
const String _kSubscribeLabel = 'Subscribe';
const String _kUnsubscribeLabel = 'Unsubscribe';
const String _kSubscribed = 'Subscribed — listening';
const String _kUnsubscribed = 'Not subscribed';
const String _kWaiting = 'No updates yet';
const String _kUpdatePrefix = 'Update from';
const String _kErrorPrefix = 'Error:';

// ---------------------------------------------------------------------------

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdaterCubit>(
      create: (_) => UpdaterCubit(
        crud: UpdaterCrud(),
        selfEmail: FirebaseAuth.instance.currentUser?.email,
      ),
      child: const _SubscriptionsView(),
    );
  }
}

class _SubscriptionsView extends StatefulWidget {
  const _SubscriptionsView();

  @override
  State<_SubscriptionsView> createState() => _SubscriptionsViewState();
}

class _SubscriptionsViewState extends State<_SubscriptionsView> {
  bool _subscribed = false;

  void _subscribe() {
    context.read<UpdaterCubit>().subscribe();
    setState(() => _subscribed = true);
  }

  void _unsubscribe() {
    unawaited(context.read<UpdaterCubit>().unsubscribe());
    setState(() => _subscribed = false);
  }

  void _announce(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_kPagePadding),
        child: BlocConsumer<UpdaterCubit, UpdaterState>(
          listener: (context, state) {
            final message = switch (state) {
              UpdaterReceived(:final beacon) =>
                '$_kUpdatePrefix ${beacon.name}',
              UpdaterError(:final message) => '$_kErrorPrefix $message',
              UpdaterInitial() => null,
            };
            if (message != null) {
              _announce(context, message);
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(_kTitle, style: defStyle),
                const Gap(_kTitleGap),
                Wrap(
                  spacing: _kButtonSpacing,
                  runSpacing: _kButtonSpacing,
                  children: [
                    ElevatedButton(
                      onPressed: _subscribed ? null : _subscribe,
                      child: const Text(_kSubscribeLabel),
                    ),
                    OutlinedButton(
                      onPressed: _subscribed ? _unsubscribe : null,
                      child: const Text(_kUnsubscribeLabel),
                    ),
                  ],
                ),
                const Gap(_kStatusGap),
                Text(
                  _subscribed ? _kSubscribed : _kUnsubscribed,
                  style: TextStyle(
                    color: _subscribed ? _kSubscribedColor : null,
                  ),
                ),
                const Gap(_kDetailGap),
                _DetailLine(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.state});

  final UpdaterState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      UpdaterInitial() => const Text(_kWaiting),
      UpdaterReceived(:final beacon) => Text(
        '$_kUpdatePrefix ${beacon.name} <${beacon.email}>\n'
        '${beacon.timestamp}',
      ),
      UpdaterError(:final message) => Text(
        '$_kErrorPrefix $message',
        style: const TextStyle(color: _kErrorColor),
      ),
    };
  }
}
