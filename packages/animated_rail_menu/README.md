A directional animated navigation rail for Flutter that owns its own `Scaffold`. Renders as a bottom bar, a side rail, or adapts automatically to screen size and orientation — with overflow handling, configurable page transitions, and tuned sizing for phones, tablets, desktop, and web.

## Features

- **Three layouts in one widget** — horizontal bottom bar, vertical side rail, or `adaptive` (vertical on tablets ≥ 600dp and landscape phones, horizontal on portrait phones).
- **Automatic overflow** — when items don't fit the available extent (or exceed an explicit `limit`), the surplus collapses behind a More button. Bottom-sheet on horizontal, inline expansion on vertical.
- **Seven page transitions** — `crossFade`, `slideLeft`, `slideRight`, `slideDirectional` (slides based on tap position relative to the current item), `scale`, `slideUp`, `slideDown`.
- **Device-class sizing presets** — `RailIcon.smallPhone`, `phone`, `smallTablet`, `tablet`, `largeTablet`, `desktop`, `web`. Each preset fixes icon size, item extent, bar extent, and indicator height to Material 3 spec and Apple HIG tap-target guidelines.
- **Haptic feedback** — configurable intensity on item tap.
- **Item spacing control** — spread evenly (`expanded`) or cluster at the start (`collapsed`).
- **Active/inactive icon pairs** — each entry declares both icons; the rail swaps them on selection.
- **Owns its `Scaffold`** — drop it in as the home of your `MaterialApp`; no wrapper required.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  animated_rail_menu: ^1.0.0
```

Then import it where you need it:

```dart
import 'package:animated_rail_menu/animated_rail_menu.dart';
```

`AnimatedRailMenu` is a `StatelessWidget` that returns a `Scaffold`, so use it as the `home` of your `MaterialApp` (or as the body of any route).

## Usage

### Basic adaptive rail

The simplest setup — four entries, layout chosen automatically from screen size and orientation:

```dart
import 'package:animated_rail_menu/animated_rail_menu.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AnimatedRailMenu(
        direction: RailDirection.adaptive,
        entries: const [
          AnimatedRailMenuEntry(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            page: HomePage(),
          ),
          AnimatedRailMenuEntry(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
            page: SearchPage(),
          ),
          AnimatedRailMenuEntry(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            label: 'Favourites',
            page: FavouritesPage(),
          ),
          AnimatedRailMenuEntry(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
            page: ProfilePage(),
          ),
        ],
      ),
    );
  }
}
```

### Tablet-sized vertical rail with directional slide and overflow limit

A six-entry vertical rail pinned to tablet sizing, sliding the page based on tap direction, and capping visible items at four (one More button + three items):

```dart
AnimatedRailMenu(
  direction: RailDirection.vertical,
  icon: RailIcon.tablet,
  transition: RailTransition.slideDirectional,
  transitionDuration: const Duration(milliseconds: 250),
  iconSpacing: MenuIconSpacing.expanded,
  haptic: HapticIntensity.medium,
  defaultIndex: 0,
  limit: 4,
  entries: const [
    AnimatedRailMenuEntry(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      page: DashboardPage(),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Inventory',
      page: InventoryPage(),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping,
      label: 'Shipping',
      page: ShippingPage(),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
      page: AnalyticsPage(),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Team',
      page: TeamPage(),
    ),
    AnimatedRailMenuEntry(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      page: SettingsPage(),
    ),
  ],
)
```

### Parameter reference

| Parameter | Type | Default | Notes |
| --- | --- | --- | --- |
| `entries` | `List<AnimatedRailMenuEntry>` | _required_ | Must be non-empty. |
| `direction` | `RailDirection` | _required_ | `horizontal`, `vertical`, or `adaptive`. |
| `defaultIndex` | `int` | `0` | Must be a valid index into `entries`. |
| `icon` | `RailIcon` | `RailIcon.phone` | Device-class sizing preset. |
| `transition` | `RailTransition` | `RailTransition.crossFade` | Page transition on entry change. |
| `transitionDuration` | `Duration` | `200ms` | Page transition duration. |
| `iconSpacing` | `MenuIconSpacing` | `expanded` | `expanded` or `collapsed`. |
| `haptic` | `HapticIntensity` | `light` | Feedback intensity on tap. |
| `limit` | `int?` | `null` | When set, caps visible items at `limit` (including the More button). Must be `>= 2`. |

## Additional information

`AnimatedRailMenu` owns the cubit lifecycle, safe area handling, overflow calculation, and page transition internally — you supply entries and configuration, the widget does the rest.
