// programs/creature_comforts/lib/src/settings/settings_screen.dart
import 'package:app_preferences_service/app_preferences_service.dart';
import 'package:biometric_gate_service/biometric_gate_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creature_comforts/descriptors/biometric_gate_descriptor.dart';
import 'package:creature_comforts/src/auth/auth_cubit.dart';
import 'package:creature_comforts/src/haptics/haptics_cubit.dart';
import 'package:extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:theme_manager/theme_manager.dart';
import 'package:theme_widget/theme_widget.dart';

/// Settings tab.
///
/// Three sections, each in its own card so adding new sections later
/// doesn't disturb existing ones:
///
///  1. Appearance — drop-in [ThemeWidget] for light/dark/system.
///  2. Haptics — radio list of all [HapticIntensity] values, bound to
///     [HapticsCubit].
///  3. Storage — three reset tiles (Disable biometric / Sign out /
///     Reset app), no confirmation dialogs by design.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _AppearanceSection(),
            _HapticsSection(),
            _StorageSection(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Appearance
// ─────────────────────────────────────────────────────────────────────────

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final cubit = ServiceRegistry.R
        .getSync<ThemeService>('Theme')
        .themeCubit;
    return _SectionCard(child: ThemeWidget(cubit: cubit));
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Haptics
// ─────────────────────────────────────────────────────────────────────────

class _HapticsSection extends StatelessWidget {
  const _HapticsSection();

  static const _labels = {
    HapticIntensity.light: 'Light',
    HapticIntensity.medium: 'Medium',
    HapticIntensity.heavy: 'Heavy',
    HapticIntensity.selection: 'Selection',
    HapticIntensity.vibrate: 'Vibrate',
    HapticIntensity.none: 'None',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Haptics',
              style: theme.textTheme.titleMedium,
            ),
          ),
          BlocBuilder<HapticsCubit, HapticIntensity>(
            builder: (context, current) {
              return Column(
                children: [
                  for (final entry in _labels.entries)
                    RadioListTile<HapticIntensity>(
                      value: entry.key,
                      groupValue: current,
                      onChanged: (v) {
                        if (v == null) return;
                        // Fire feedback at the *new* intensity so the
                        // user gets immediate physical confirmation of
                        // their selection.
                        v.trigger();
                        context.read<HapticsCubit>().setIntensity(v);
                      },
                      title: Text(entry.value),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Storage
// ─────────────────────────────────────────────────────────────────────────

class _StorageSection extends StatelessWidget {
  const _StorageSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Storage',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const _DisableBiometricTile(),
          const _SignOutTile(),
          const _ResetAppTile(),
        ],
      ),
    );
  }
}

class _DisableBiometricTile extends StatelessWidget {
  const _DisableBiometricTile();

  Future<void> _onTap(BuildContext context) async {
    context.read<HapticsCubit>().tap();
    final gate = ServiceRegistry.R.getSync<BiometricGateService>(
      BiometricGateDescriptor.kName,
    );
    final result = await gate.disable();
    if (!context.mounted) return;
    result.match(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric disabled.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.fingerprint),
      title: const Text('Disable biometric'),
      subtitle: const Text(
        'Removes stored biometric credentials. You stay signed in.',
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () => _onTap(context),
    );
  }
}

class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  Future<void> _onTap(BuildContext context) async {
    context.read<HapticsCubit>().tap();
    final gate = ServiceRegistry.R.getSync<BiometricGateService>(
      BiometricGateDescriptor.kName,
    );
    await gate.disable();
    if (!context.mounted) return;
    await context.read<AuthCubit>().signOut();
    // No mounted check follows — AuthCubit emits Unauthenticated, the
    // auth gate routes away, and this widget is disposed.
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Sign out'),
      subtitle: const Text(
        'Clears biometric and Firebase session. You sign in again.',
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () => _onTap(context),
    );
  }
}

class _ResetAppTile extends StatelessWidget {
  const _ResetAppTile();

  Future<void> _onTap(BuildContext context) async {
    context.read<HapticsCubit>().tap();

    // Step 1: biometric.
    final gate = ServiceRegistry.R.getSync<BiometricGateService>(
      BiometricGateDescriptor.kName,
    );
    await gate.disable();

    // Step 2: clear all preferences (theme, haptic intensity,
    // notifications-decided flag, anything else stored under prefs).
    final prefs = ServiceRegistry.R
        .getSync<AppPreferences>('AppPreferences')
        .prefs;
    await prefs.clear();

    // Step 3: clear Firestore offline cache. terminate() must come
    // before clearPersistence() — clearing requires a closed instance.
    try {
      await FirebaseFirestore.instance.terminate();
      await FirebaseFirestore.instance.clearPersistence();
    }
    // ignore: avoid_catches_without_on_clauses
    catch (_) {
      // Best effort — if the cache won't clear, the sign-out below is
      // still the user-visible "this worked" signal.
    }

    if (!context.mounted) return;

    // Step 4: sign out — emits Unauthenticated, auth gate routes away.
    await context.read<AuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        Icons.delete_forever,
        color: theme.colorScheme.error,
      ),
      title: Text(
        'Reset app',
        style: TextStyle(color: theme.colorScheme.error),
      ),
      subtitle: const Text(
        'Clears everything: biometric, session, theme, and all '
        'preferences. App returns to first-launch state.',
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () => _onTap(context),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared
// ─────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
