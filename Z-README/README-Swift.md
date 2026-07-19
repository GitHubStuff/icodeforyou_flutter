# Swift Interview Questions (iOS, macOS, iPadOS)

100 questions covering language fundamentals, memory management, concurrency, UIKit/SwiftUI, and Apple-platform specifics.

---

## 1. What is the difference between `let` and `var`?

`let` declares an immutable binding; the reference or value cannot be reassigned after initialization. `var` declares a mutable binding. For value types (structs, enums), `let` also makes the contents immutable. For reference types (classes), `let` only locks the reference — the object's mutable properties can still change.

## 2. What is the difference between a struct and a class?

Structs are value types, copied on assignment, stack-allocated when possible, and don't support inheritance. Classes are reference types, heap-allocated, support inheritance, and have identity (compared with `===`). Structs get a memberwise initializer for free; classes don't. Swift's standard library prefers structs.

## 3. What are optionals and why do they exist?

An optional (`T?`) represents a value that may be `T` or `nil`. They exist to make the absence of a value explicit in the type system, eliminating null-pointer crashes by forcing you to handle the `nil` case via unwrapping, optional chaining, or `if let`/`guard let`.

## 4. What is optional chaining?

Optional chaining (`?.`) lets you call properties, methods, and subscripts on an optional that might currently be `nil`. If any link in the chain is `nil`, the entire expression evaluates to `nil` without crashing. The result is always optional.

## 5. What's the difference between `if let` and `guard let`?

Both unwrap optionals. `if let` introduces the unwrapped value inside its block. `guard let` introduces it into the enclosing scope and requires an `else` branch that exits the scope (return, throw, break, continue). Use `guard` for early exit; use `if let` when you only need the value briefly.

## 6. What is force unwrapping and when should you use it?

The `!` operator force-unwraps an optional, crashing if it's `nil`. Use it only when you can guarantee the value is non-nil — typically with IBOutlets, resources known to ship with the app bundle, or after an explicit check. Otherwise, prefer safe unwrapping.

## 7. What is an implicitly unwrapped optional?

Declared with `T!`, it's an optional that auto-unwraps when accessed. Used primarily for IBOutlets and two-phase initialization where a value will be set immediately after init but can't be set during init.

## 8. What is the nil-coalescing operator?

`a ?? b` returns `a` if it's non-nil (unwrapped), otherwise `b`. Both sides must be type-compatible. Useful for providing defaults: `let name = user.name ?? "Anonymous"`.

## 9. What's the difference between `Any` and `AnyObject`?

`Any` can represent an instance of any type, including value types, function types, and optionals. `AnyObject` represents an instance of any class type only. `AnyObject` is used for bridging with Objective-C APIs.

## 10. What are tuples?

Tuples group multiple values into a single compound value. They can be named or unnamed: `let point = (x: 1, y: 2)`. Useful for returning multiple values from a function without defining a struct. Not suitable for complex data structures.

## 11. What is type inference?

Swift's compiler deduces the type of an expression from context. `let x = 42` infers `Int`; `let y = 3.14` infers `Double`. Reduces verbosity but you should annotate types when intent isn't obvious or when inference produces the wrong type.

## 12. What are computed properties?

Properties that don't store a value but compute one on access via a getter (and optionally a setter). Defined with `var` because their value can change. Distinct from stored properties, which hold an actual value.

## 13. What are property observers?

`willSet` and `didSet` blocks that run before/after a stored property's value changes. `willSet` receives `newValue`; `didSet` receives `oldValue`. Don't fire during initialization. Useful for reactive updates.

## 14. What is lazy initialization?

A `lazy var` property is not computed until first accessed. Must be `var` because its initial state changes (uninitialized → initialized). Useful for expensive setup or properties that depend on `self`.

## 15. What is the difference between `static` and `class` methods?

Both are type-level methods. `static` cannot be overridden by subclasses. `class` can be overridden. `class` is only available on classes; `static` works on structs, enums, and classes. In a class context, `static` is shorthand for `class final`.

## 16. What is a protocol?

A protocol defines a blueprint of methods, properties, and requirements that conforming types must implement. Protocols enable polymorphism without inheritance and are central to Swift's "protocol-oriented programming."

## 17. What is a protocol extension?

An extension on a protocol that provides default implementations of its requirements or adds new methods. Conforming types inherit these defaults automatically but can override them. Enables shared behavior across unrelated types.

## 18. What is the difference between protocol-oriented and object-oriented programming?

OOP organizes behavior through class hierarchies and inheritance. POP composes behavior through protocols and protocol extensions, works with value types, and avoids the rigidity of single inheritance. Swift's standard library is built on POP.

## 19. What are associated types in protocols?

Placeholders for types used within a protocol, declared with `associatedtype`. The conforming type specifies the concrete type. Example: `Collection` has `associatedtype Element`. Makes protocols generic.

## 20. What is the difference between `some` and `any` for protocols?

`some Protocol` is an opaque type — a specific concrete type the compiler knows but the caller doesn't, preserving type identity. `any Protocol` is an existential type — a box that can hold any conforming type, with runtime dispatch and some performance cost.

## 21. What are generics?

Generics let you write code that works with any type while preserving type safety. `func swap<T>(_ a: inout T, _ b: inout T)` works for any type `T`. The compiler specializes generic code per concrete type.

## 22. What are generic constraints?

Restrictions on type parameters using `where` clauses or inline constraints: `func sum<T: Numeric>(_ values: [T]) -> T`. Constraints let you call protocol methods on the generic type inside the function body.

## 23. What is ARC?

Automatic Reference Counting tracks the number of strong references to a class instance. When the count drops to zero, the instance is deallocated. ARC runs at compile time, inserting retain/release calls. Value types are not managed by ARC.

## 24. What is a retain cycle?

When two objects hold strong references to each other, ARC can never deallocate them. Common in closures that capture `self` strongly while `self` retains the closure, or in delegate patterns without `weak`.

## 25. What's the difference between `weak` and `unowned`?

Both prevent retain cycles. `weak` references are optional and become `nil` when the referent is deallocated — safe but always optional. `unowned` references are non-optional and assume the referent outlives them — crash if accessed after deallocation. Use `unowned` only when lifetimes are guaranteed.

## 26. How do you break a retain cycle in a closure?

Use a capture list: `{ [weak self] in ... }` or `{ [unowned self] in ... }`. With `weak`, `self` is optional inside the closure and typically unwrapped with `guard let self else { return }`.

## 27. What is an escaping closure?

A closure marked `@escaping` may be stored or called after the function returns. Non-escaping closures must finish executing before the function returns. Escaping closures require explicit `self.` access and are common in async callbacks.

## 28. What is `@autoclosure`?

An attribute that wraps an argument expression in a closure automatically, delaying evaluation. Used in `assert`, `&&`, `||`, and `??` to avoid evaluating the right side unless needed.

## 29. What is the difference between `throws` and `rethrows`?

`throws` declares that a function may throw an error. `rethrows` declares that a function only throws if one of its closure arguments throws. `map`, `filter`, etc. use `rethrows` so they're non-throwing when given non-throwing closures.

## 30. What is the `Result` type?

`Result<Success, Failure: Error>` is an enum with `.success(Success)` and `.failure(Failure)` cases. Encapsulates the outcome of an operation that can fail, replacing completion handlers that took both a value and an error. Common before async/await.

## 31. What is `defer`?

A `defer` block executes when the enclosing scope exits, regardless of how it exits (return, throw, fall-through). Use for cleanup: closing files, releasing locks, etc. Multiple defers execute in reverse order.

## 32. What are extensions?

Extensions add new functionality (methods, computed properties, initializers, protocol conformance) to existing types without modifying their source. You can extend types you don't own, including standard library and framework types.

## 33. What is the difference between `==` and `===`?

`==` tests value equality, requiring `Equatable` conformance. `===` tests reference identity — whether two references point to the same instance. `===` only applies to class types.

## 34. What is `Equatable` and `Hashable`?

`Equatable` requires `==`. `Hashable` extends `Equatable` and requires `hash(into:)`, allowing instances to be used as dictionary keys or set members. The compiler synthesizes both for structs/enums whose stored properties conform.

## 35. What is `Codable`?

A typealias for `Encodable & Decodable`. Lets types serialize to and from external formats like JSON. The compiler synthesizes conformance automatically when all stored properties are `Codable`. Customize via `CodingKeys` and custom `init(from:)` / `encode(to:)`.

## 36. What is the difference between `map`, `flatMap`, and `compactMap`?

`map` transforms each element, returning an array of results. `compactMap` does the same but filters out `nil` results, useful when the transform returns optionals. `flatMap` on sequences concatenates nested sequences; on optionals, it's like `map` but flattens nested optionals.

## 37. What is `reduce`?

`reduce` combines all elements of a sequence into a single value using an initial value and a combining closure: `[1,2,3].reduce(0, +)` returns `6`. A `reduce(into:)` variant is more efficient when the accumulator is mutable.

## 38. What is the difference between `filter` and `compactMap`?

`filter` keeps elements that satisfy a predicate, preserving type. `compactMap` transforms and removes `nil` results, potentially changing the element type. Use `filter` for selection, `compactMap` for transformation-plus-filtering.

## 39. What is a higher-order function?

A function that takes another function as a parameter or returns one. `map`, `filter`, `reduce`, and `sorted(by:)` are higher-order. They enable functional-style data transformations.

## 40. What is a closure in Swift?

A self-contained block of code that can be passed around and executed later. Closures capture variables from their surrounding scope. Functions and methods are special cases of closures. Syntax: `{ (params) -> ReturnType in body }`.

## 41. What is the difference between Grand Central Dispatch and OperationQueue?

GCD is a low-level C-based API for dispatching work to queues. `OperationQueue` is a higher-level Objective-C class built on GCD that supports dependencies, cancellation, priorities, and KVO. Both are largely superseded by Swift Concurrency for new code.

## 42. What is async/await?

Swift's native concurrency syntax. `async` functions can suspend and resume; `await` marks suspension points. Eliminates callback pyramids and Result-based plumbing. Introduced in Swift 5.5.

## 43. What is an actor?

A reference type that protects its mutable state from data races by serializing access. Properties and methods on an actor must be accessed with `await` from outside the actor. Use for shared mutable state in concurrent code.

## 44. What is `@MainActor`?

A global actor that runs work on the main thread. Mark UI-touching types or methods with `@MainActor` to guarantee they run on the main thread. Replaces manual `DispatchQueue.main.async` calls in modern Swift.

## 45. What is `Sendable`?

A marker protocol indicating a type is safe to share across concurrency domains. Value types whose members are `Sendable` get conformance automatically. Classes must be `final` and immutable, or use internal synchronization. The compiler enforces `Sendable` at concurrency boundaries.

## 46. What is structured concurrency?

A model where async tasks have a defined scope tied to their parent. `async let` and `TaskGroup` create child tasks whose lifetimes are bounded by the parent. If the parent is cancelled, children are cancelled. Replaces ad-hoc unstructured task spawning.

## 47. What is a `Task`?

A unit of asynchronous work. `Task { ... }` creates an unstructured top-level task. `Task.detached` runs without inheriting context. Tasks can be cancelled, return values, and be awaited.

## 48. What is `TaskGroup`?

A scope for running multiple child tasks concurrently and collecting their results. Created via `withTaskGroup` or `withThrowingTaskGroup`. The group waits for all children before returning.

## 49. What is a continuation?

A bridge between callback-based APIs and async/await. `withCheckedContinuation` and `withCheckedThrowingContinuation` let you wrap completion-handler APIs in async functions. Must be resumed exactly once.

## 50. What is the difference between `DispatchQueue.main` and `MainActor`?

`DispatchQueue.main` is a GCD queue tied to the main thread. `@MainActor` is a compile-time mechanism that statically guarantees code runs on the main thread. `MainActor` is preferred in modern Swift; it catches threading bugs at compile time.

## 51. What is KVO?

Key-Value Observing — an Objective-C mechanism for observing changes to a property. In Swift, requires the property to be `@objc dynamic` on an `NSObject` subclass. Combine and SwiftUI's `@Published` largely replace KVO.

## 52. What is `@objc` and `dynamic`?

`@objc` exposes a Swift declaration to the Objective-C runtime, enabling selectors, KVO, and target-action. `dynamic` forces dispatch through the Objective-C runtime, enabling method swizzling and KVO.

## 53. What is a protocol witness table?

The compiler-generated table that maps protocol requirements to a conforming type's implementations. Used for dynamic dispatch when calling protocol methods on existential or generic values.

## 54. What is method dispatch in Swift?

Swift uses four dispatch modes: static (inline/direct, for structs and `final`/`private` class members), vtable (for non-final class members), witness table (for protocol methods), and Objective-C message dispatch (for `@objc dynamic`).

## 55. What is the difference between `final` and `private` for performance?

Both enable static dispatch. `final` prevents subclass overrides; `private` restricts access to the enclosing file. Either gives the compiler enough information to devirtualize calls.

## 56. What are property wrappers?

Types that wrap a property and inject behavior on get/set. Declared with `@propertyWrapper` and a `wrappedValue`. Examples: `@State`, `@Published`, `@UserDefault`. The user writes `@MyWrapper var x` and gets the wrapper's behavior transparently.

## 57. What are result builders?

A compiler feature that transforms a sequence of expressions into a single combined result. SwiftUI's view DSL uses `@ViewBuilder`. Declared with `@resultBuilder` and required methods like `buildBlock`.

## 58. What is the difference between `frozen` and non-frozen enums?

`@frozen` enums promise their cases won't change in future library versions, allowing exhaustive switches without `@unknown default`. Non-frozen public enums in libraries should be switched with `@unknown default` for forward compatibility.

## 59. What are raw values and associated values in enums?

Raw values are a single underlying value per case, all of the same type, declared with `: RawValue`. Associated values are data attached to each case, potentially different per case. An enum can have one or the other, not both.

## 60. What is pattern matching in Swift?

`switch`, `if case`, `guard case`, and `for case` match values against patterns, including tuple patterns, value-binding patterns, optional patterns, and enum-case patterns. Enables expressive destructuring.

## 61. What is `inout`?

An `inout` parameter is passed by reference; mutations inside the function are reflected at the call site. Calls require `&` prefix. Used for in-place mutation, but pure functional alternatives are usually preferred.

## 62. What is the difference between value semantics and reference semantics?

Value semantics: assigning or passing copies the value; mutations don't affect the original. Reference semantics: assigning copies the reference; mutations are visible through all references. Structs/enums have value semantics; classes have reference semantics.

## 63. What is copy-on-write?

An optimization where value types containing reference-typed storage (like `Array`, `Dictionary`) share storage on copy and only duplicate when mutated. Gives value semantics with reference-type performance for reads.

## 64. What is a subscript?

A type member that lets instances be accessed with bracket syntax: `dict["key"]`, `array[0]`. Declared with `subscript(params) -> ReturnType`. Can be read-only or read-write, and can take any parameters.

## 65. What are failable initializers?

Initializers that can return `nil`, declared with `init?` or `init!`. Used when initialization can fail due to invalid input. The result is an optional.

## 66. What is the difference between designated and convenience initializers?

A designated initializer fully initializes all stored properties and calls a superclass designated initializer. A convenience initializer (`convenience init`) must call another initializer on the same class and ultimately a designated one. Convenience initializers provide alternative entry points.

## 67. What is two-phase initialization?

Swift's safety rule: phase one, every stored property is given an initial value; phase two, properties may be customized further and `self` becomes usable. Designed to prevent reading uninitialized memory.

## 68. What is the responder chain?

In UIKit/AppKit, the ordered chain of objects that get a chance to handle an event (touches, key presses, actions). Starts at the first responder and walks up through superviews, view controllers, the window, and the application object.

## 69. What is the difference between `frame` and `bounds`?

`frame` is the view's rectangle in its superview's coordinate system. `bounds` is the view's rectangle in its own coordinate system, typically with origin `.zero`. Modifying `bounds.origin` scrolls the view's content.

## 70. What is Auto Layout?

A constraint-based layout system where you express relationships between views (equal width, leading edge to leading edge, etc.) and the engine solves for view positions. Replaces manual frame math and adapts to varying screen sizes.

## 71. What is the view lifecycle of a `UIViewController`?

`init` → `loadView` → `viewDidLoad` (once) → `viewWillAppear` → `viewWillLayoutSubviews` → `viewDidLayoutSubviews` → `viewDidAppear` → (use) → `viewWillDisappear` → `viewDidDisappear`. `viewDidLoad` fires once; appear/disappear fire each time the view enters/exits the hierarchy.

## 72. What is the difference between `viewDidLoad` and `viewWillAppear`?

`viewDidLoad` runs once after the view is loaded into memory — use for one-time setup. `viewWillAppear` runs every time the view is about to be displayed — use for refreshing data or updating UI state that may have changed.

## 73. What is the App Lifecycle in iOS?

In UIKit with scenes: app launches → `application(_:didFinishLaunchingWithOptions:)` → scenes connect → `sceneWillEnterForeground` → `sceneDidBecomeActive` → (use) → `sceneWillResignActive` → `sceneDidEnterBackground`. Older single-window apps use `UIApplicationDelegate` equivalents.

## 74. What is SwiftUI?

Apple's declarative UI framework introduced in 2019. Views are value types describing UI state; the framework diffs and renders. Built around `View`, `@State`, `@Binding`, `@Environment`, and the `body` computed property.

## 75. What is the difference between `@State` and `@Binding`?

`@State` is a SwiftUI-managed source of truth owned by a view, for private mutable state. `@Binding` is a two-way reference to state owned elsewhere, passed into a child view so the child can read and write the parent's state.

## 76. What is `@StateObject` vs `@ObservedObject`?

Both wrap reference types conforming to `ObservableObject`. `@StateObject` owns the object — created once and tied to the view's lifetime. `@ObservedObject` does not own the object — the view receives it from elsewhere and doesn't manage its lifecycle. Mixing these up causes lifecycle bugs.

## 77. What is `@EnvironmentObject`?

A SwiftUI property wrapper that reads an `ObservableObject` from the environment, injected via `.environmentObject(_:)` higher in the view tree. Useful for app-wide state without prop-drilling.

## 78. What is `@Environment` in SwiftUI?

A property wrapper that reads values from SwiftUI's environment by key path: color scheme, locale, dismiss action, etc. Custom environment values can be defined via `EnvironmentKey`.

## 79. What is the `body` property in SwiftUI?

A computed property of type `some View` that describes the view's current rendering. SwiftUI invalidates and recomputes `body` when observed state changes. It should be pure and fast.

## 80. What is `@Observable` (Swift 5.9+)?

A macro that replaces `ObservableObject` and `@Published`. Classes marked `@Observable` automatically track property access for SwiftUI dependency tracking, simplifying the model layer.

## 81. What is the difference between `Combine` and async/await?

Combine is a reactive streams framework — values over time, with operators like `map`, `debounce`, `flatMap`. async/await handles single asynchronous results. `AsyncSequence` bridges the gap. Combine is mature but not actively expanded; new APIs lean on async/await.

## 82. What is `URLSession`?

The standard API for HTTP networking on Apple platforms. Provides data, download, and upload tasks via callbacks, Combine publishers, and async methods (`data(from:)`, `download(from:)`). Configured via `URLSessionConfiguration`.

## 83. What is the App Sandbox?

A security mechanism that restricts an app's access to system resources and user data. iOS apps are always sandboxed. macOS apps distributed via the Mac App Store must be sandboxed; outside it, sandboxing is opt-in but required for many entitlements.

## 84. What are entitlements?

Key-value pairs that grant an app specific capabilities (push notifications, iCloud, HealthKit, app groups, network access on macOS sandboxed apps). Embedded in the code signature and checked by the OS at runtime.

## 85. What is Info.plist?

A property list file containing app metadata: bundle identifier, version, supported orientations, required device capabilities, usage descriptions for sensitive APIs (camera, location), URL schemes, and so on. Required for every bundle.

## 86. What are usage description keys?

`Info.plist` keys like `NSCameraUsageDescription` that explain why your app needs access to a sensitive API. Required — apps crash on first access to the API if the key is missing.

## 87. What is App Transport Security?

A networking policy that requires HTTPS with strong ciphers by default. Plaintext HTTP requires explicit exceptions in `Info.plist` (`NSAppTransportSecurity` → `NSAllowsArbitraryLoads` or per-domain exceptions). Reviewers scrutinize broad exceptions.

## 88. What is the difference between iOS, iPadOS, and macOS development?

iOS targets iPhone with single-window UIKit/SwiftUI. iPadOS extends iOS with multitasking, multiple windows (scenes), pointer/keyboard support, and Stage Manager. macOS uses AppKit historically or SwiftUI today, with menus, multiple resizable windows, and a richer interaction model. Mac Catalyst lets iPad apps run on macOS with UIKit.

## 89. What is Mac Catalyst?

A technology that lets a UIKit/iPadOS app run on macOS by adapting iPad idioms to Mac conventions (window chrome, menu bar, mouse interactions). Single codebase, separate target. SwiftUI multiplatform projects are the modern alternative for new apps.

## 90. What is the difference between AppKit and UIKit?

AppKit is the macOS UI framework (`NSWindow`, `NSView`, `NSViewController`). UIKit is the iOS/iPadOS/tvOS framework (`UIWindow`, `UIView`, `UIViewController`). Different class names, lifecycles, and conventions despite overlapping concepts. SwiftUI unifies them with a single declarative API.

## 91. What is Core Data?

Apple's object graph and persistence framework. Models entities and relationships, persists via SQLite (or other stores), supports change tracking, undo, and CloudKit sync. Heavier than raw SQLite or Codable+JSON but powerful for graph-shaped data.

## 92. What is SwiftData?

Apple's modern persistence framework introduced in 2023, built on Core Data internals but exposed via Swift macros. Uses `@Model` on classes and integrates tightly with SwiftUI. Simpler API surface than Core Data for common cases.

## 93. What is `UserDefaults`?

A persistent key-value store for small amounts of data (settings, preferences). Backed by a plist on disk. Not for large data, not encrypted. Synced across devices when using `NSUbiquitousKeyValueStore`.

## 94. What is the Keychain?

A secure, encrypted storage for credentials, tokens, certificates, and keys. Survives app reinstall (by default). Use for any sensitive data; don't use `UserDefaults`. API is C-based — most projects use a wrapper.

## 95. What is GCD's `DispatchSemaphore`?

A counting semaphore for synchronizing access to a resource. `wait()` decrements (blocking if zero); `signal()` increments. Used to limit concurrency or coordinate between threads. In modern Swift, prefer actors or `AsyncSemaphore` patterns.

## 96. What is a memory leak in Swift?

Memory that ARC can never reclaim, typically caused by retain cycles. Detected with Xcode's Memory Graph Debugger and Instruments' Leaks/Allocations templates. Distinct from "abandoned memory," which is reachable but unused.

## 97. What are Swift Package Manager and CocoaPods?

Both manage third-party dependencies. SPM is Apple's first-party tool, integrated into Xcode, declarative `Package.swift`. CocoaPods is a Ruby-based community tool predating SPM, still widely used in older projects. SPM is the default for new work.

## 98. What is XCTest?

Apple's unit and UI testing framework. Test classes subclass `XCTestCase`; test methods start with `test`. Assertions: `XCTAssertEqual`, `XCTAssertTrue`, etc. Supports async tests with `async` test methods and expectations for callback-based code.

## 99. What is the Swift Testing framework?

A newer testing framework introduced in Swift 6, using macros (`@Test`, `#expect`) instead of XCTest's subclassing model. Supports parameterized tests, traits, and parallel execution. Coexists with XCTest; either or both can be used in a target.

## 100. What is the difference between debug and release builds?

Debug builds include symbols, assertions, and minimal optimization for fast compile and good debugging. Release builds enable whole-module optimization, strip symbols, disable assertions, and produce smaller, faster binaries. Release builds are what you ship.
