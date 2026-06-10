// programs/creature_comforts/lib/app.dart
import 'package:creature_comforts/descriptors/auth_service_descriptor.dart'
    show AuthServiceDescriptor;
import 'package:creature_comforts/descriptors/last_fed_descriptor.dart'
    show LastFedServiceDescriptor;
import 'package:creature_comforts/src/auth/auth_cubit.dart' show AuthCubit;
import 'package:creature_comforts/src/auth/auth_service.dart' show AuthService;
import 'package:creature_comforts/src/auth/auth_state.dart'
    show
        AuthInitializing,
        AuthState,
        Authenticated,
        BiometricLocked,
        Unauthenticated;
import 'package:creature_comforts/src/auth/biometric_unlock_screen.dart'
    show BiometricUnlockScreen;
import 'package:creature_comforts/src/auth/login_screen.dart' show LoginScreen;
import 'package:creature_comforts/src/haptics/haptics_cubit.dart'
    show HapticsCubit;
import 'package:creature_comforts/src/last_fed/last_fed_cubit.dart'
    show LastFedCubit;
import 'package:creature_comforts/src/shell/app_shell.dart' show AppShell;
import 'package:creature_comforts_service/creature_comforts_service.dart'
    show LastFedService;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart' show ServiceRegistry;
import 'package:theme_manager/theme_manager.dart'
    show MaterialThemeCubit, MaterialThemeState, ThemeService;

/// Root widget of the program.
///
/// Owns three concerns at the top of the tree:
///
/// 1. Provides [AuthCubit], [HapticsCubit], and [LastFedCubit] to the
///    entire subtree via [MultiBlocProvider], so any screen can react
///    to sign-in events, fire haptic feedback at the user-chosen
///    intensity, and read the latest feeding timestamp + derived
///    [CrittersStatus] without prop-drilling any of them.
/// 2. Listens to the [MaterialThemeCubit] that the [ThemeService] owns,
///    so the [MaterialApp]'s `themeMode`, `theme`, and `darkTheme` rebuild
///    whenever the user toggles dark mode in Settings.
/// 3. Routes between the four top-level auth states using a
///    [BlocBuilder<AuthCubit, AuthState>]:
///
///      - [AuthInitializing] → splash
///      - [Unauthenticated]  → [LoginScreen]
///      - [BiometricLocked]  → [BiometricUnlockScreen]
///      - [Authenticated]    → [AppShell] (the rail)
class CreatureComfortsApp extends StatelessWidget {
  const CreatureComfortsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = ServiceRegistry.R
        .getSync<ThemeService>('Theme')
        .themeCubit;
    final authService = ServiceRegistry.R.getSync<AuthService>(
      AuthServiceDescriptor.kName,
    );
    final lastFedService = ServiceRegistry.R.getSync<LastFedService>(
      LastFedServiceDescriptor.kName,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authService: authService)..bootstrap(),
        ),
        BlocProvider<HapticsCubit>(
          create: (_) => HapticsCubit()..bootstrap(),
        ),
        BlocProvider<LastFedCubit>(
          create: (_) => LastFedCubit(lastFed: lastFedService),
        ),
      ],
      child: BlocBuilder<MaterialThemeCubit, MaterialThemeState>(
        bloc: themeCubit,
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Creature Comforts',
            debugShowCheckedModeBanner: false,
            theme: themeState.light,
            darkTheme: themeState.dark,
            themeMode: themeState.mode,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

/// Routes the visible screen based on [AuthState].
///
/// Pulled out as a private widget rather than inlined in [CreatureComfortsApp]
/// so the auth gate has its own [BuildContext] under the cubit providers —
/// otherwise `context.read<AuthCubit>()` calls inside the routed screens
/// would have to reach above the [BlocBuilder] into a parent context.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitializing() => const _Splash(),
          Unauthenticated() => const LoginScreen(),
          BiometricLocked() => BiometricUnlockScreen(user: state.user),
          Authenticated() => AppShell(user: state.user),
        };
      },
    );
  }
}

/// Plain centred spinner shown while [AuthCubit.bootstrap] resolves the
/// initial state from a stored Firebase session and biometric preference.
class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
