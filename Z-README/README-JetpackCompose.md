# Jetpack Compose Interview Questions

50 questions covering Jetpack Compose fundamentals, state management, recomposition, layout, side effects, navigation, and interop.

---

## 1. What is Jetpack Compose?

Android's modern declarative UI toolkit, stable since 2021. You describe UI as composable functions of state; the framework manages rendering and updates. Replaces the View/XML system for new Android UI work. Built with Kotlin, leverages coroutines and Flow throughout.

## 2. What is a composable function?

A Kotlin function annotated `@Composable` that emits UI when invoked. Can only be called from another composable. Returns `Unit` — the UI is built as a side effect of execution into the Compose runtime's slot table.

## 3. What does `@Composable` actually do?

It marks a function as a participant in the Compose runtime. The compiler plugin transforms it to accept an implicit `Composer` parameter and to track read/write of state, enabling smart recomposition. Without the annotation, a function can't call other composables.

## 4. What is recomposition?

The process of re-invoking composable functions when their inputs change, to update the UI. Compose tracks which composables read which state and only re-runs the ones whose state changed. Recomposition can skip composables whose inputs are unchanged and stable.

## 5. What triggers recomposition?

A state read inside a composable. When that state's value changes, Compose schedules the composables that read it for recomposition. Other things (parameter changes, parent recomposition with new arguments) can also cascade re-runs.

## 6. What is `remember`?

A composable that stores a value across recompositions in the current composition's slot table. Without `remember`, every recomposition would recreate the value. Use for objects that should persist within a composition but don't need to survive configuration changes.

## 7. What is `rememberSaveable`?

Like `remember` but also persists across activity/process recreation (configuration changes, process death). Uses `Saver` to serialize the value into the saved-instance-state bundle. Works automatically for primitives, strings, and `Parcelable`/`Serializable`.

## 8. What is the difference between `remember` and `rememberSaveable`?

`remember` survives recomposition only. `rememberSaveable` also survives configuration changes and process death. Use `rememberSaveable` for UI state the user would expect to keep (form input, scroll position); `remember` for transient state.

## 9. What is `mutableStateOf`?

Creates an observable state holder of type `MutableState<T>`. Reading its `value` registers a dependency in the current composable; writing triggers recomposition of dependents. Almost always wrapped in `remember` to survive recomposition: `val x = remember { mutableStateOf(0) }`.

## 10. What is the difference between `State` and `MutableState`?

`State<T>` is read-only — exposes `value` for reading. `MutableState<T>` extends `State<T>` and adds writable `value`. Expose `State<T>` from APIs that should be read-only; keep `MutableState<T>` private inside view models or the source-of-truth class.

## 11. What is the `by` delegate for state?

`var count by remember { mutableStateOf(0) }` — uses property delegation so you read/write `count` directly instead of `count.value`. Requires importing `getValue`/`setValue` from `androidx.compose.runtime`. Pure syntactic sugar.

## 12. What is state hoisting?

Moving state out of a composable into a caller, making the composable stateless. The stateless version takes `value: T` and `onValueChange: (T) -> Unit` parameters. Improves reusability, testability, and lets multiple consumers share state.

## 13. Why prefer stateless composables?

They're easier to reuse, preview, and test. They make the data flow obvious — state goes down, events go up. A stateless composable doesn't lock you into a specific source-of-truth strategy (state, view model, parent, etc.).

## 14. What does "state goes down, events go up" mean?

The unidirectional data flow pattern. Parent owns state and passes immutable values down to children. Children emit events (lambda callbacks) upward when something happens. The parent updates state in response, triggering recomposition with new values.

## 15. What is the Compose compiler plugin?

A Kotlin compiler plugin that transforms `@Composable` functions: inserts the implicit `Composer` parameter, generates recomposition tracking, and analyzes stability of parameters. Without it, composable functions wouldn't compile.

## 16. What is stability in Compose?

A property of types that lets the runtime skip recomposition when arguments haven't changed. A type is stable if its equality is well-defined and its public properties don't change without notifying Compose. Immutable types, primitives, and `@Stable`/`@Immutable`-annotated types qualify.

## 17. What is `@Stable` and `@Immutable`?

`@Immutable` promises a type's properties never change after construction. `@Stable` is a weaker promise: properties can change but the type notifies Compose (typically by being state-backed) and `equals` is consistent. Both let the compiler treat the type as skippable.

## 18. What does it mean for a composable to be "skippable"?

When called with the same arguments as last time, Compose can skip executing the function and reuse the previous output. Requires all parameters to be stable. Non-skippable composables run every time their parent recomposes.

## 19. What is `derivedStateOf`?

Creates a state whose value is computed from other state, recomputing only when its inputs change and only emitting when the result actually changes. Use to avoid recomposing on every keystroke when you only care about a derived condition (`isButtonEnabled = text.length > 5`).

## 20. What is the difference between `remember(key) { ... }` and `LaunchedEffect(key) { ... }`?

`remember(key)` recomputes the value when the key changes. `LaunchedEffect(key)` launches a coroutine when first composed and cancels/relaunches when the key changes. One is for values; the other for side-effects.

## 21. What is `LaunchedEffect`?

A composable that launches a coroutine tied to the composition. Enters on first composition, cancels when leaving the composition, and restarts when its keys change. Used for one-shot async work that should follow the composable's lifecycle.

## 22. What is `DisposableEffect`?

A side-effect composable for non-coroutine resources that need cleanup. Provides an `onDispose { ... }` block that runs when the effect leaves the composition or keys change. Used for registering listeners, subscriptions, or observers.

## 23. What is `SideEffect`?

A composable that runs a block after every successful recomposition. Used to push Compose state into non-Compose objects (e.g., updating a system bar color). No keys, no cancellation, no coroutine support.

## 24. What is `rememberCoroutineScope`?

Returns a `CoroutineScope` tied to the composition's lifetime. Use to launch coroutines in response to events (button clicks) rather than as a side-effect of composition. Cancelled automatically when the composable leaves the composition.

## 25. When do you use `LaunchedEffect` vs `rememberCoroutineScope`?

`LaunchedEffect` launches automatically when the composable enters the composition or keys change — for setup/teardown work. `rememberCoroutineScope` gives you a scope to launch from event callbacks — for user-triggered work. Different lifecycles, different use cases.

## 26. What is `produceState`?

A side-effect that converts non-Compose async sources into Compose state. The lambda runs as a coroutine and assigns to `value`; readers get a `State<T>`. Useful for bridging Flows, callbacks, or one-shot async loads into the composition.

## 27. What is `collectAsState` / `collectAsStateWithLifecycle`?

Extensions on `Flow` that collect emissions and expose them as `State`. `collectAsStateWithLifecycle` is the Android-aware variant that pauses collection when the lifecycle is below STARTED, preventing wasted work and crashes on background updates.

## 28. What is the difference between `Modifier.padding` placement and order?

Modifiers chain left-to-right, each wrapping the next. `Modifier.padding(8.dp).background(Red)` paints red on the inner (padded) area. `Modifier.background(Red).padding(8.dp)` paints red on the outer area and pads inside. Order matters — always.

## 29. What is `Modifier`?

A chained, immutable description of decorations and behaviors applied to a composable: padding, size, background, click handling, etc. Each composable typically accepts a `modifier: Modifier = Modifier` parameter as its first optional argument so callers can customize layout and behavior.

## 30. Why should a composable accept a `Modifier` parameter?

It lets callers customize size, padding, background, and behavior without forking the composable. Convention: place it as the first optional parameter, default to `Modifier`, and apply it to the root layout element. Don't apply caller-provided modifiers to inner elements.

## 31. What are `Row`, `Column`, and `Box`?

Layout composables. `Row` arranges children horizontally; `Column` vertically; `Box` stacks them, allowing positioning via alignment. All accept arrangement and alignment parameters. Compose's equivalents of `LinearLayout` and `FrameLayout`.

## 32. What is `LazyColumn` / `LazyRow`?

Lazy lists that only compose visible items, like `RecyclerView`. Items are declared inside a DSL block (`items`, `item`, `itemsIndexed`). Pass a stable `key` per item for correct state retention and performance during inserts/removes.

## 33. Why is `key` important in `LazyColumn`?

Without a stable key, Compose identifies items by their position. Inserting at the top causes every subsequent item to be treated as "changed," losing per-item state (selection, expanded state) and animations. Provide `key = { it.id }` to track identity.

## 34. What is `Scaffold`?

A Material composable providing the standard app structure slots: top bar, bottom bar, floating action button, snackbar host, drawer, and content area. Handles insets and slot coordination so you don't have to.

## 35. What is Material3 vs Material2 in Compose?

`androidx.compose.material` (Material2) implements Material Design 2. `androidx.compose.material3` implements Material You / Material Design 3 with dynamic color and updated components. New apps should use Material3.

## 36. What is the Compose Navigation library?

`androidx.navigation:navigation-compose` — defines a `NavHost` with composable destinations addressed by route strings (or type-safe routes in newer versions). `NavController` exposes `navigate`, `popBackStack`, etc. Plays well with `Scaffold` for bottom bars and drawers.

## 37. How do you pass arguments between Compose Navigation destinations?

Encode them in the route path (`"detail/{id}"`) or query string, then extract from `NavBackStackEntry.arguments`. Recent versions support type-safe navigation with serializable route objects, avoiding manual string assembly.

## 38. What is a `CompositionLocal`?

A way to pass values implicitly down the composition tree without threading them through every parameter. Built-in examples: `LocalContext`, `LocalDensity`, `LocalLifecycleOwner`. Define your own with `compositionLocalOf` or `staticCompositionLocalOf`.

## 39. When should you use `CompositionLocal`?

Sparingly — for cross-cutting values that many composables read (theme, density, layout direction) where parameter-threading would be onerous. Don't use it as a general dependency-injection mechanism; it hurts clarity and testability.

## 40. What is the difference between `compositionLocalOf` and `staticCompositionLocalOf`?

`compositionLocalOf` triggers recomposition of all readers when the value changes — for values that change at runtime. `staticCompositionLocalOf` doesn't track reads, so changes invalidate the entire subtree, but reads are cheaper — for values that rarely or never change.

## 41. What is `MaterialTheme`?

A composable that provides color scheme, typography, and shape definitions to its content via `CompositionLocal`s. Wrap your app in `MaterialTheme { ... }` so Material components pick up your design tokens.

## 42. How do you handle dark mode in Compose?

Use `isSystemInDarkTheme()` to pick a color scheme and pass it to `MaterialTheme`. Material3 also supports dynamic color (`dynamicLightColorScheme` / `dynamicDarkColorScheme`) on Android 12+ for system-derived palettes.

## 43. How do you handle configuration changes?

Compose has no special configuration-change handling — by default the activity is recreated and composition restarts. Survive state across recreation with `rememberSaveable` or by hoisting state into a `ViewModel`. The latter is the standard for non-trivial state.

## 44. How do `ViewModel`s integrate with Compose?

Use `viewModel()` from `androidx.lifecycle:lifecycle-viewmodel-compose` (or `hiltViewModel()` with Hilt) to retrieve a `ViewModel` scoped to the current navigation entry or activity. Expose `StateFlow`/`State` from the view model and collect in the composable.

## 45. How do you interop between Compose and Views?

Embed Compose in a View hierarchy with `ComposeView` (XML) or `setContent` (programmatic). Embed Views in Compose with `AndroidView` (creates and updates a View). `AndroidViewBinding` wraps a generated ViewBinding. Useful for incremental migration.

## 46. What are Compose Previews?

`@Preview`-annotated composable functions render in Android Studio without running the app. Supports parameters (`showBackground`, `widthDp`, `uiMode`), parameter providers, and multi-preview annotations to test multiple configurations (themes, font sizes, locales) at once.

## 47. How do you test composables?

Use `androidx.compose.ui:ui-test-junit4`. `createComposeRule()` provides a `ComposeTestRule`. Set content with `setContent`, find nodes via semantics (`onNodeWithText`, `onNodeWithTag`), perform actions (`performClick`), and assert state. Runs on-device or via Robolectric.

## 48. What is the difference between `Modifier.clickable` and `Modifier.pointerInput`?

`Modifier.clickable` is the high-level tap handler with built-in ripple, accessibility, and indication. `Modifier.pointerInput` is the low-level gesture API for custom gestures (drag, multi-touch, custom tap timing). Use `clickable` unless you need custom behavior.

## 49. How do you avoid unnecessary recomposition?

Hoist state to the right level so changes invalidate the smallest subtree. Use stable/immutable parameter types. Prefer lambdas captured by `remember` if they reference state. Defer state reads with `derivedStateOf` or by passing lambdas instead of values. Use the Compose Compiler metrics to find non-skippable composables.

## 50. What are the Compose Compiler metrics?

A compiler-generated report showing which composables are skippable, restartable, and stable, and which parameters are unstable. Enable via Gradle to diagnose recomposition performance problems. Pair with the Layout Inspector's recomposition counts to find hotspots.
