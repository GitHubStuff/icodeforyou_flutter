// programs/creature_comforts/lib/src/profile/profile_screen.dart
import 'package:creature_comforts/descriptors/auth_service_descriptor.dart';
import 'package:creature_comforts/src/auth/auth_cubit.dart';
import 'package:creature_comforts/src/auth/auth_service.dart';
import 'package:creature_comforts/src/auth/auth_user.dart';
import 'package:creature_comforts/src/haptics/haptics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart';

/// Profile tab — replaces LOGIN once the user is authenticated.
///
/// Shows a small identity block (avatar + name + email) and offers the
/// two operations users expect on this screen:
///
///  - **Sign out** — drops back to [LoginScreen] via [AuthCubit.signOut].
///  - **Send password reset** — sends a reset link to the user's email
///    via [AuthService.sendPasswordResetEmail]. Useful for password
///    rotation without having to remember the current one.
///
/// No confirmation dialogs — same convention as Settings; trust the user.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.user, super.key});

  final AuthUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _resetting = false;

  Future<void> _onSignOutPressed() async {
    context.read<HapticsCubit>().tap();
    await context.read<AuthCubit>().signOut();
    // No mounted check needed — AuthCubit emits Unauthenticated, the
    // auth gate routes away from this screen, and we're disposed.
  }

  Future<void> _onResetPasswordPressed() async {
    context.read<HapticsCubit>().tap();
    setState(() => _resetting = true);
    final auth = ServiceRegistry.R
        .getSync<AuthService>(AuthServiceDescriptor.kName);
    final result = await auth.sendPasswordResetEmail(email: widget.user.email);
    if (!mounted) return;
    setState(() => _resetting = false);
    result.match(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _Avatar(user: widget.user),
                  const SizedBox(height: 24),
                  _IdentityBlock(user: widget.user),
                  const SizedBox(height: 48),
                  FilledButton.icon(
                    onPressed: _resetting ? null : _onResetPasswordPressed,
                    icon: _resetting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.email_outlined),
                    label: const Text('Send password reset email'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _onSignOutPressed,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circle avatar with the user's initials, sized for the profile screen.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 48,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        _initialsFor(user),
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Up to two uppercase initials. Prefers display-name words; falls back
  /// to the first two characters of the email's local part.
  static String _initialsFor(AuthUser user) {
    final name = user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
      final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
      if (letters.isNotEmpty) return letters;
    }
    final local = user.email.split('@').first;
    if (local.isEmpty) return '?';
    return local.substring(0, local.length >= 2 ? 2 : 1).toUpperCase();
  }
}

/// Display name (or email fallback) on top, email below as a muted
/// secondary line. Centred for the profile layout.
class _IdentityBlock extends StatelessWidget {
  const _IdentityBlock({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasName =
        user.displayName != null && user.displayName!.trim().isNotEmpty;
    return Column(
      children: [
        Text(
          hasName ? user.displayName! : user.email,
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (hasName) ...[
          const SizedBox(height: 4),
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
