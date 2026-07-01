# SwiftUI Interview Questions

50 questions covering SwiftUI fundamentals, state management, layout, navigation, performance, and platform integration.

---

## 1. What is SwiftUI?

Apple's declarative UI framework introduced in 2019 for iOS 13+, macOS 10.15+, watchOS, and tvOS. You describe what the UI should look like for a given state, and the framework handles rendering and updates. Built around value-type views, state-driven updates, and a result-builder DSL.

## 2. What is the difference between declarative and imperative UI?

Imperative UI (UIKit) requires you to manually mutate the view hierarchy in response to events. Declarative UI (SwiftUI) describes the UI as a function of state — when state changes, the framework computes a new description and applies the diff. Less code, fewer state-sync bugs.

## 3. What is a `View` in SwiftUI?

A protocol with one requirement: a `body` computed property returning `some View`. Views are value types (structs), cheaply created and destroyed. They're descriptions of UI, not the UI itself — SwiftUI renders them through underlying platform primitives.

## 4. What does `some View` mean?

An opaque return type. The body returns a specific concrete view type known to the compiler but hidden from callers. Lets SwiftUI compose deeply nested generic types (`VStack<TupleView<...>>`) without forcing you to write them out.

## 5. What is the `body` property?

A computed property invoked by SwiftUI whenever the view needs to be re-evaluated due to a dependency change. It should be pure and fast — no side effects, no expensive work. SwiftUI may call it many times per frame.

## 6. What is `@State`?

A property wrapper for view-local mutable state owned by SwiftUI. The framework stores the value outside the view struct (which is itself immutable) and triggers a re-render when the value changes. Use for simple, private state like toggles, text input, or selection.

## 7. What is `@Binding`?

A two-way reference to state owned elsewhere. A parent passes `$state` to a child accepting `@Binding var value`; the child can read and write, and the parent sees the changes. Used for reusable controls like `TextField` and `Toggle`.

## 8. What is the difference between `@State` and `@Binding`?

`@State` owns the value; `@Binding` is a reference to a value owned somewhere else. `@State` is initialized with a default; `@Binding` is initialized by passing in a binding (`$value`). Use `@State` at the source of truth, `@Binding` to thread it down.

## 9. What is `@StateObject`?

A property wrapper for a reference type conforming to `ObservableObject`, owned by the view. SwiftUI creates the object once for the view's lifetime and keeps it alive across re-renders. Use it where the object is first created.

## 10. What is `@ObservedObject`?

A property wrapper for an `ObservableObject` that the view observes but does not own. The view receives the object from outside and does not control its lifecycle. If you use `@ObservedObject` where you should use `@StateObject`, the object can be recreated on every parent re-render.

## 11. What is `@EnvironmentObject`?

A property wrapper that reads an `ObservableObject` from the SwiftUI environment, injected by an ancestor view via `.environmentObject(_:)`. Useful for app-wide state without passing it through every intermediate view.

## 12. What is `@Environment`?

A property wrapper that reads values from SwiftUI's environment by key path: `\.colorScheme`, `\.dismiss`, `\.locale`, `\.scenePhase`, and custom keys. The environment is inherited down the view tree and can be overridden with `.environment(_:_:)`.

## 13. What is `@Observable` (Swift 5.9+)?

A macro that replaces `ObservableObject` and `@Published`. Mark a class `@Observable` and SwiftUI tracks property access automatically. Views observing such an object only re-render when properties they actually read change, which is finer-grained than `ObservableObject`.

## 14. What is `ObservableObject`?

A protocol for reference types that publish changes. Properties marked `@Published` automatically trigger `objectWillChange` notifications. Any view observing the object via `@StateObject` / `@ObservedObject` / `@EnvironmentObject` re-renders when any published property changes.

## 15. What is `@Published`?

A property wrapper used on properties of an `ObservableObject`. When the property's value changes, it publishes a notification through the object's `objectWillChange` publisher, triggering view updates.

## 16. What is the difference between `ObservableObject` and `@Observable`?

`ObservableObject` requires `@Published` per property and notifies all observers on any published change. `@Observable` (macro-based) tracks per-property access and notifies only views that read the specific property that changed — better performance, less boilerplate.

## 17. What is the difference between `VStack`, `HStack`, and `ZStack`?

`VStack` arranges children vertically, `HStack` horizontally, `ZStack` layered front-to-back along the z-axis. All accept `alignment` and `spacing` parameters. Stacks size themselves around their children unless given a frame.

## 18. What is `LazyVStack` / `LazyHStack`?

Lazy variants of `VStack` / `HStack` used inside `ScrollView`. They only create child views as they scroll into view, unlike eager stacks which build all children upfront. Use for long lists; non-lazy stacks are fine for small fixed groups.

## 19. What is the difference between `List` and `ScrollView` + `LazyVStack`?

`List` provides platform-styled rows, swipe actions, selection, edit mode, and section headers/footers for free. `ScrollView` + `LazyVStack` is more flexible for custom layouts but you implement those features yourself. Pick `List` unless you need custom row styling beyond what `List` allows.

## 20. What is `ForEach`?

A view that produces a view per element of a collection. Each element needs a stable identity, either by conforming to `Identifiable` or by passing a key path: `ForEach(items, id: \.self)`. Used inside stacks, lists, and other containers.

## 21. Why does `ForEach` need an identifier?

SwiftUI uses identity to diff the collection across renders — to know which views to insert, remove, or reuse. Without stable identity (e.g., using array indices when items can move), animations and state retention break.

## 22. What is `NavigationStack`?

The modern navigation container (iOS 16+, macOS 13+) for push-style navigation. Drives navigation from a `path` binding, enabling deep linking and programmatic navigation. Replaces the older `NavigationView` for new code.

## 23. What is the difference between `NavigationView` and `NavigationStack`?

`NavigationView` is the legacy container; on iPad/Mac it could split into a multi-column layout. `NavigationStack` is push-only, path-driven, and deprecates `NavigationView` for iOS 16+. For split-view layouts, use `NavigationSplitView`.

## 24. What is `NavigationSplitView`?

A multi-column navigation container (iOS 16+, macOS 13+) for sidebar/content/detail layouts. Adapts to size class: shows columns on iPad/Mac and collapses to a stack on iPhone. Replaces the multi-column behavior of the old `NavigationView`.

## 25. What is `NavigationLink`?

A view that triggers navigation when tapped. Modern usage with `NavigationStack`: `NavigationLink(value: someValue)` pushes onto the path, and a `.navigationDestination(for:)` modifier higher up renders the destination view based on the value's type.

## 26. What is `.sheet`, `.fullScreenCover`, `.popover`?

Modal presentation modifiers. `.sheet` shows a card that can be dismissed by swipe. `.fullScreenCover` covers the entire screen until dismissed programmatically. `.popover` shows a popover anchored to a view (a regular popover on iPad/Mac, a sheet on iPhone). All driven by a bound boolean or optional item.

## 27. What is `.alert` and `.confirmationDialog`?

Modal modifiers for user prompts. `.alert` is a blocking dialog with title, message, and buttons. `.confirmationDialog` is the modern API for action sheets — a list of choices anchored to a sheet/popover depending on platform. Both are state-driven.

## 28. What is a `ViewModifier`?

A protocol with a `body(content:)` method that wraps a view in additional behavior or styling. Used to package reusable view transformations. Apply with `.modifier(_:)` or write an extension on `View` to expose it as a method.

## 29. What is the difference between a custom `View` and a `ViewModifier`?

A `View` produces UI from scratch. A `ViewModifier` transforms an existing view (adds padding, background, gesture, etc.). Use views for new UI components; use modifiers for cross-cutting decorations applied to many views.

## 30. What is `@ViewBuilder`?

A result builder that lets a closure or function return multiple views as a single composite view. Used implicitly in `body` and in container parameters like `VStack { ... }`. Enables the SwiftUI DSL syntax.

## 31. What is `GeometryReader`?

A container that exposes its parent-proposed size and coordinate space via a `GeometryProxy`. Use it for layout that depends on available size (e.g., percentage-based widths). Greedy — fills available space — which can surprise you.

## 32. How does SwiftUI's layout system work?

A three-step negotiation: the parent proposes a size to the child, the child returns its desired size, the parent places the child. Children can return any size; parents decide final placement. Modifiers wrap views in additional layout steps.

## 33. What is the difference between `.frame(width:height:)` and `.frame(maxWidth:maxHeight:)`?

`.frame(width:height:)` sets a fixed size; the view ignores the proposed size in those dimensions. `.frame(maxWidth:maxHeight:)` lets the view grow up to the maximum within the proposed size. Use `.infinity` to fill available space.

## 34. What does `.padding()` do?

Adds space around a view by wrapping it in a padding modifier that proposes a smaller size to the child and reports back a larger size. Without arguments, uses system-default padding; with arguments, uses specified edges/amounts.

## 35. What is the difference between `.background` and `.overlay`?

`.background` draws behind the view; `.overlay` draws in front. Both can take a view or a shape. Useful for cards, badges, and decorations. The decorating view is sized to match the host view by default.

## 36. What is `.clipShape` vs `.mask`?

`.clipShape` clips a view to a shape — anything outside the shape isn't rendered or hit-tested. `.mask` uses a view's alpha as a mask, allowing soft edges and gradients. Both control visibility geometrically.

## 37. What are `Spacer` and `Divider`?

`Spacer` is a flexible view that expands along its stack's axis, pushing siblings to the edges. `Divider` is a thin line separating content, automatically styled per platform. Both are useful inside stacks.

## 38. What is the difference between `EnvironmentValues` and `PreferenceKey`?

`EnvironmentValues` flow down the view tree from ancestor to descendant. `PreferenceKey` values flow up from descendant to ancestor — children write preferences, ancestors read them via `.onPreferenceChange`. Use preferences for child-to-parent communication.

## 39. What is `@FocusState`?

A property wrapper for managing keyboard focus among controls. Bind it to multiple fields with `.focused($field, equals: .name)` and assign to programmatically focus or dismiss the keyboard. Replaces UIKit's first-responder dance.

## 40. What is `@SceneStorage` and `@AppStorage`?

`@AppStorage` is a property wrapper backed by `UserDefaults` — app-wide persistent values. `@SceneStorage` persists per-scene state across app launches, useful for restoring per-window state (selected tab, scroll position). Both behave like `@State` for the view's purposes.

## 41. How do you animate changes in SwiftUI?

Wrap state mutation in `withAnimation { state = newValue }` to animate all dependent views, or attach `.animation(_:value:)` to a view to animate when a specific value changes. Implicit animations apply to all changes; explicit animations (`withAnimation`) scope to a single mutation.

## 42. What is the difference between implicit and explicit animation?

Implicit: `.animation(.default, value: someState)` — SwiftUI animates affected views whenever `someState` changes. Explicit: `withAnimation { someState = newValue }` — only this specific mutation is animated. Explicit gives more control and avoids unexpected animations from unrelated state changes.

## 43. What is `matchedGeometryEffect`?

A modifier that links two views via a shared identifier and namespace. When one disappears and the other appears, SwiftUI animates between their geometries — used for hero transitions and morphing layouts.

## 44. What is `Canvas` in SwiftUI?

A view (iOS 15+) that gives you an immediate-mode drawing surface via a `GraphicsContext`. Use for custom drawing that would be expensive as composed views — particle systems, charts, complex shapes. Pairs well with `TimelineView` for animations.

## 45. What is `TimelineView`?

A view that re-renders on a schedule (every frame, every second, at specific dates). Used for clocks, countdowns, and animations driven by time rather than state mutations.

## 46. How do you bridge UIKit/AppKit into SwiftUI?

Conform to `UIViewRepresentable` / `UIViewControllerRepresentable` (iOS) or `NSViewRepresentable` / `NSViewControllerRepresentable` (macOS). Implement `makeUIView`/`updateUIView` to create and update the underlying view. Use a `Coordinator` for delegate callbacks.

## 47. How do you bridge SwiftUI into UIKit/AppKit?

Wrap a SwiftUI view in `UIHostingController(rootView:)` (iOS) or `NSHostingController(rootView:)` / `NSHostingView(rootView:)` (macOS). Push or present like any other view controller.

## 48. What causes unnecessary re-renders in SwiftUI?

Common causes: using `@ObservedObject` instead of `@StateObject` (object recreated each render), broad `ObservableObject` updates triggering views that don't use the changed property, computing expensive work in `body`, and using identity-unstable IDs in `ForEach`. `@Observable` and proper state ownership mitigate most of these.

## 49. How do you debug SwiftUI performance?

Xcode's Instruments includes a "SwiftUI" template that shows view body invocations, redundant updates, and slow renders. `Self._printChanges()` inside `body` (debug only) logs which dependency triggered the update. Profile in release builds; debug builds aren't representative.

## 50. What are the limitations of SwiftUI?

Earlier OS targets miss many APIs (`NavigationStack`, `@Observable`, `Charts` etc. require recent OS versions). Some UIKit/AppKit features still require bridging (advanced text editing, complex scroll behavior, certain camera/AR controls). Layout debugging is harder than UIKit's frame-based model. Mature codebases often mix SwiftUI with UIKit/AppKit where SwiftUI is insufficient.
