// animated_rail_menu/example/lib/main.dart
// ignore_for_file: public_member_api_docs

import 'package:animated_rail_menu/animated_rail_menu.dart'
    show
        AnimatedRailMenu,
        MenuIconSpacing,
        RailDirection,
        RailIcon,
        RailTransition;
import 'package:animated_widgets/animated_widgets.dart'
    show PulseWidget, SplashConfig, SplashCubit, SplashScreen;
import 'package:app_preferences_service/app_preferences_service.dart'
    show AppPreferencesDescriptor;
import 'package:creature_comfort/firebase_options.dart';
import 'package:creature_comfort/src/state/general_cubit.dart'
    show GeneralCubit;
import 'package:custom_widgets/custom_widgets.dart' show SizedSpinner;
import 'package:extensions/enum/src/haptic_intensity.dart' show HapticIntensity;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_locator/service_locator.dart' show ServiceRegistry;
import 'package:theme_manager/theme_manager.dart'
    show CrossFadeTheme, MaterialRoot, MaterialThemeCubit, inputDecorationTheme;
import 'package:theme_service/theme_service.dart'
    show ThemeDescriptor, ThemeService;

import 'src/nav_entries.dart' show navEntries;

/// Demonstrates how the three Navigator layers coexist with the rail:
///
///   Layer 1 (root navigator)   -> full-screen routes that COVER the rail.
///   Layer 2 (the rail shell)   -> AnimatedRailMenu, switches body by index.
///   Layer 3 (branch navigator) -> per-tab pushes that KEEP the rail visible.
///
/// Home    tab -> Layer 3: push a detail page, the rail stays on screen.
/// Library tab -> Layer 1: push a full-screen editor, the rail disappears.
///
/// State-preservation note: AnimatedRailMenu swaps pages with an
/// AnimatedSwitcher, so an inactive tab is DISPOSED on switch. The tap
/// counters survive a push/pop, but reset when you leave and re-enter a
/// tab. That reset is exactly what go_router's
/// StatefulShellRoute.indexedStack removes -- the trade-off to weigh
/// before adopting it.

// programs/creature_comfort/lib/main.dart
// ignore_for_file: always_use_package_imports

ThemeData _dark = ThemeData.dark(useMaterial3: true).copyWith(
  extensions: const [CrossFadeTheme()],
  inputDecorationTheme: inputDecorationTheme(
    const ColorScheme.dark(),
    focusedErrorColor: Colors.red,
    errorColor: Colors.redAccent,
  ),
);
ThemeData _lite = ThemeData.light(useMaterial3: true).copyWith(
  extensions: const [CrossFadeTheme()],
  inputDecorationTheme: inputDecorationTheme(
    const ColorScheme.dark(),
    focusedErrorColor: Colors.red,
    errorColor: Colors.redAccent,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Lets the user set the brightness to dark, light, system
  ServiceRegistry.R.stage(const AppPreferencesDescriptor.platform());
  ServiceRegistry.R.stage(
    ThemeDescriptor(
      name: 'Theme',
      dark: _dark,
      light: _lite,
    ),
  );
  await ServiceRegistry.R.register('Theme');

  runApp(providers);
}

final providers = MultiBlocProvider(
  providers: [
    BlocProvider<GeneralCubit>.value(
      value: GeneralCubit(),
    ),
    BlocProvider<MaterialThemeCubit>.value(
      value: ServiceRegistry.R.getSync<ThemeService>('Theme').themeCubit,
    ),
    BlocProvider.value(
      value: SplashCubit(
        splashConfig: const SplashConfig(
          splashDuration: Duration(milliseconds: 1500),
          crossfadeDuration: Duration(milliseconds: 250),
        ),
      ),
    ),
  ],
  child: MaterialRoot(splashWidget),
);

Widget get splashWidget {
  return SplashScreen(
    splashWidget: pulse,
    intermediateWidget: const SizedSpinner(size: 60),
    landingPage: _animatedRailMenu,
    tasks: const [],
  );
  // unawaited(StatusBarChameleon.setStatusBarHidden(hidden: false));
  // return const FullScreenColor();
}

Widget get pulse {
  return const PulseWidget(
    child: FlutterLogo(size: 200),
  );
}

final _animatedRailMenu = AnimatedRailMenu(
  entries: navEntries,
  direction: RailDirection.adaptive,
  icon: RailIcon.phone,
  transition: RailTransition.crossFade,
  transitionDuration: const Duration(milliseconds: 700),
  iconSpacing: MenuIconSpacing.collapsed,
  haptic: HapticIntensity.medium,
  limit: null,
);

/*




void main() => runApp(const ExampleApp());









class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rail navigation demo',
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: const RailHome(),
    );
  }
}

class RailHome extends StatelessWidget {
  const RailHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedRailMenu(
      direction: RailDirection.adaptive,
      transition: _kTransition,
      transitionDuration: _kTransitionDuration,
      limit: 5, // forces a More button so overflow stays visible with 6 entries
      entries: [
        AnimatedRailMenuEntry(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          page: _NestedTab(builder: (_) => const HomePage()),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.video_library_outlined,
          activeIcon: Icons.video_library,
          label: 'Library',
          page: LibraryTab(),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: 'Search',
          page: _PlainTab(title: 'Search'),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: 'Favorites',
          page: _PlainTab(title: 'Favorites'),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          page: _PlainTab(title: 'Profile'),
        ),
        const AnimatedRailMenuEntry(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
          page: SettingsPage(),
        ),
      ],
    );
  }
}

/// Wraps [builder]'s first route in a private [Navigator] so pushes stay
/// inside the tab and the rail remains visible (Layer 3).
///
/// The [PopScope] routes the system back gesture to this inner Navigator
/// before it reaches the root. Each tab that needs an internal stack pays
/// this boilerplate -- which is precisely what StatefulShellRoute removes.
class _NestedTab extends StatefulWidget {
  const _NestedTab({required this.builder});

  final WidgetBuilder builder;

  @override
  State<_NestedTab> createState() => _NestedTabState();
}

class _NestedTabState extends State<_NestedTab> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final navigator = _navigatorKey.currentState;
        if (navigator == null) return;
        unawaited(navigator.maybePop());
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: widget.builder,
          settings: settings,
        ),
      ),
    );
  }
}



class _HomeRootState extends State<HomeRoot> {
  int _taps = 0;

  void _openDetail() {
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const HomeDetail()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Taps on this tab: $_taps'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => setState(() => _taps++),
              child: const Text('Increment'),
            ),
            const SizedBox(height: 24),
            const Text('Rail-visible push (Layer 3):'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _openDetail,
              child: const Text('Open detail (rail stays)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detail page pushed onto the Home tab's own Navigator. The rail is still
/// visible behind/around this Scaffold; popping returns to [HomeRoot] with
/// its tap count intact.
class HomeDetail extends StatelessWidget {
  const HomeDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home / Detail')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pushed on the tab Navigator.'),
            const Text('The rail is still on screen.'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Pop back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Library tab. Pushes on the ROOT navigator, so the route covers the rail
/// entirely (Layer 1). Popping restores the rail at this exact tab with the
/// tap count preserved, because this page stays mounted beneath the push.
class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  int _taps = 0;

  void _openEditor() {
    unawaited(
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(builder: (_) => const FullScreenEditor()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Taps on this tab: $_taps'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => setState(() => _taps++),
              child: const Text('Increment'),
            ),
            const SizedBox(height: 24),
            const Text('Full-screen push (Layer 1):'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _openEditor,
              child: const Text('Open editor (rail hidden)'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen route pushed on the root navigator. It owns its Scaffold and
/// covers the rail. `Navigator.of(context).pop()` finds the root navigator
/// (the nearest one above this route) and returns to the rail.
class FullScreenEditor extends StatelessWidget {
  const FullScreenEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full-screen editor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pushed on the ROOT Navigator.'),
            const Text('The rail is gone while this is open.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Pop back to the rail'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain destination with no internal stack. Reachable directly or via the
/// overflow "More" menu when [AnimatedRailMenu.limit] hides it from the bar.
class _PlainTab extends StatelessWidget {
  const _PlainTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title tab')),
    );
  }
}

*/
