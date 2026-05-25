# Kotlin Interview Questions

100 questions covering Kotlin language fundamentals, null safety, coroutines, functional features, interoperability, and Android-specific topics.

---

## 1. What is Kotlin?

A statically-typed, JVM-compatible programming language developed by JetBrains, first released in 2011 and made Android's preferred language by Google in 2019. Targets the JVM, Android, JavaScript, and native binaries (Kotlin/Native). Designed to be concise, null-safe, and fully interoperable with Java.

## 2. What is the difference between `val` and `var`?

`val` declares a read-only reference; you can't reassign it after initialization (like Java's `final`). `var` declares a mutable reference. Neither implies immutability of the underlying object — a `val` holding a `MutableList` can still have items added.

## 3. What is the difference between `val` and `const val`?

`val` is evaluated at runtime and can hold any expression result. `const val` is a compile-time constant; must be a primitive or `String`, must be top-level or inside an `object`/`companion object`, and is inlined by the compiler. Use `const val` for true constants.

## 4. What is type inference in Kotlin?

The compiler deduces the type from the initializer: `val x = 42` infers `Int`. You can still annotate explicitly when intent isn't obvious or when you want a different type than inferred. Function return types can also be inferred for expression-body functions.

## 5. What is null safety in Kotlin?

Types are non-nullable by default. To allow null, append `?`: `String?`. The compiler rejects unsafe access on nullable types, forcing you to handle the null case via safe calls (`?.`), Elvis (`?:`), `!!`, or smart casts. Eliminates most NPEs.

## 6. What is the safe call operator `?.`?

`a?.b` returns `null` if `a` is `null`, otherwise `a.b`. Chains short-circuit: `user?.address?.city` is `null` if any link is null. Result is always nullable.

## 7. What is the Elvis operator `?:`?

`a ?: b` returns `a` if non-null, otherwise `b`. Used for defaults: `val name = user?.name ?: "Anonymous"`. The right side can also throw or return: `val id = user?.id ?: return`.

## 8. What does `!!` do?

The non-null assertion operator. `x!!` returns `x` if non-null; throws `NullPointerException` if `x` is null. Use sparingly — usually a sign you should redesign for null safety. Acceptable when you can prove non-nullness but the compiler can't.

## 9. What is a smart cast?

The compiler narrows a type after a check, so you don't need an explicit cast. Inside `if (x is String) { ... }`, `x` is treated as `String`. Same for null checks: after `if (x != null)`, `x` is non-nullable. Only works on stable values (val, local var without lambda capture).

## 10. What is the difference between `is` and `as`?

`is` is a type check that enables smart casts: `if (x is String)`. `as` is a cast that throws `ClassCastException` on failure. `as?` is a safe cast that returns `null` on failure: `val s = x as? String`.

## 11. What is the difference between `==` and `===`?

`==` is structural equality, compiled to `equals()` with null handling. `===` is referential equality — same instance. Opposites are `!=` and `!==`. Use `==` for value comparison, `===` rarely (mostly for identity checks).

## 12. What are data classes?

Classes whose primary purpose is to hold data. Declared with `data class`. The compiler generates `equals`, `hashCode`, `toString`, `copy`, and `componentN` functions based on properties in the primary constructor. Reduces boilerplate dramatically.

## 13. What does the `copy()` function do on a data class?

Creates a new instance with optionally overridden properties: `user.copy(name = "New")`. The standard way to "mutate" immutable data — return a modified copy rather than changing in place.

## 14. What are destructuring declarations?

`val (a, b) = pair` unpacks an object into multiple variables via its `componentN` operators. Works with data classes, `Pair`, `Triple`, `Map.Entry`, and anything else defining `component1`, `component2`, etc.

## 15. What is the difference between a class and an object?

`class` is a template instantiated with constructors. `object` declares a singleton — one instance, no constructor, eagerly initialized on first access. Use `object` for singletons, utility namespaces, and stateless helpers.

## 16. What is a companion object?

A singleton tied to a class, declared inside it: `companion object { ... }`. Members are accessed via the class name like Java's static members but are actually instance methods on the companion. Used for factory functions and constants.

## 17. What is the difference between `companion object` and `object`?

`object` is a top-level (or nested) singleton, accessed by its own name. `companion object` lives inside a class and is accessed through the class name. A class can have at most one companion object.

## 18. What is an interface in Kotlin?

A contract that can declare abstract members and provide default implementations. Unlike Java pre-8, defaults have always been a Kotlin feature. Interfaces cannot have backing fields but can have abstract properties.

## 19. What is the difference between an abstract class and an interface?

Abstract classes can have constructors, mutable state with backing fields, and a single inheritance slot. Interfaces have no constructor, no backing fields, and a class can implement many. Prefer interfaces unless you need concrete state.

## 20. What is a sealed class?

A class whose subclasses are restricted to the same file (or module, for `sealed interface` in modern Kotlin). Used for closed type hierarchies — the compiler knows all subtypes and enables exhaustive `when` expressions without an `else` branch.

## 21. What is a sealed interface?

Like a sealed class but as an interface, allowing a type to be in multiple sealed hierarchies. Introduced in Kotlin 1.5. Same exhaustiveness benefits as sealed classes.

## 22. What is an enum class?

A fixed set of named instances of a type. Each constant is a singleton instance. Supports properties, methods, and per-constant overrides. Use for closed sets of values; use sealed classes when constants need to carry different shapes of data.

## 23. What is the difference between a sealed class and an enum?

Enum constants are singletons with the same structure. Sealed subclasses can have different state, multiple instances, and parameterized constructors. Use enums for simple constant sets; sealed for variant types with payloads.

## 24. What is a `when` expression?

Kotlin's switch replacement. Each branch matches a condition (value, range, type, predicate). When used as an expression, must be exhaustive — covering all possibilities or providing `else`. With sealed types or enums, the compiler checks exhaustiveness.

## 25. What is the difference between `when` as a statement and as an expression?

As a statement: branches are optional, no exhaustiveness required. As an expression: every code path must produce a value, so all cases must be covered. The compiler enforces this when the result is used.

## 26. What is a primary constructor?

The constructor declared in the class header: `class User(val name: String, val age: Int)`. Properties declared with `val`/`var` in the primary constructor become member properties. The primary constructor cannot contain code — use `init` blocks.

## 27. What is an `init` block?

Code that runs as part of construction, inside the class body. Multiple `init` blocks run in declaration order, interleaved with property initializers. Used for validation or setup that primary-constructor parameters can't express.

## 28. What is a secondary constructor?

Additional constructors declared with `constructor(...)`. They must delegate to the primary constructor (if one exists) via `: this(...)` and run after the primary constructor and init blocks.

## 29. What is the difference between a property and a field?

A Kotlin property is an abstract concept: a getter and optionally a setter. The backing field exists only when the property uses the default accessor or references `field` explicitly. You can have computed properties with no backing field.

## 30. What is `lateinit`?

A modifier for non-null `var` properties whose value will be assigned after construction but before first read. Avoids needing to use a nullable type or unsafe `!!`. Accessing before initialization throws `UninitializedPropertyAccessException`. Doesn't work with primitives.

## 31. What is `lazy`?

A delegate that initializes a `val` on first access. `val x by lazy { computeExpensive() }`. Thread-safe by default; configurable with `LazyThreadSafetyMode`. Use for expensive initialization that may not be needed.

## 32. What is the difference between `lateinit` and `lazy`?

`lateinit` is for `var`, requires manual initialization, works with non-primitive types. `lazy` is for `val`, initializes itself on first access via a lambda. Use `lazy` when you can compute the value; use `lateinit` when something external must inject it.

## 33. What is delegation in Kotlin?

A pattern where an object forwards calls to another object. Kotlin supports class delegation (`class Foo : Bar by impl`) and property delegation (`val x by delegate`). The compiler generates the forwarding code.

## 34. What are property delegates?

Objects that provide custom getter/setter behavior for a property via `getValue`/`setValue` operator functions. Standard delegates include `lazy`, `Delegates.observable`, `Delegates.vetoable`, and map-backed delegates. You can write your own.

## 35. What are extension functions?

Functions that add new behavior to existing types without modifying them: `fun String.lastChar(): Char = this[length - 1]`. Statically resolved — not real members, no polymorphism. Useful for utility methods and DSLs.

## 36. What is the difference between an extension function and a member function?

Member functions are part of the class and dispatch dynamically. Extension functions are static helpers resolved at the call site based on the declared (not runtime) type of the receiver. Members win when there's a name conflict.

## 37. Can extension functions be overridden?

No. They're statically dispatched based on the compile-time type of the receiver. If you need polymorphism, declare a member function or open an interface.

## 38. What are extension properties?

Properties added to existing types via extension syntax: `val String.lastChar: Char get() = this[length - 1]`. Cannot have backing fields since they're not real members — must be computed.

## 39. What are higher-order functions?

Functions that take functions as parameters or return functions. Standard library examples: `map`, `filter`, `forEach`, `reduce`. Enable functional programming patterns and DSLs.

## 40. What is a lambda expression?

An anonymous function literal: `{ x, y -> x + y }`. The last expression is the return value. Can capture variables from the enclosing scope. Most common form of passing functions in Kotlin.

## 41. What is the `it` keyword in lambdas?

The implicit name for a single-parameter lambda: `list.filter { it > 0 }`. Available only when the lambda has exactly one parameter and you don't declare it explicitly. Improves brevity for short lambdas.

## 42. What is a trailing lambda?

When the last parameter of a function is a function type, you can write the lambda outside the parentheses: `list.forEach { println(it) }`. If the lambda is the only argument, parentheses can be omitted entirely.

## 43. What is the difference between `inline`, `noinline`, and `crossinline`?

`inline` functions have their bodies copied to the call site at compile time, eliminating lambda allocation and enabling non-local returns. `noinline` opts a specific lambda parameter out of inlining. `crossinline` keeps the lambda inlined but forbids non-local returns from it.

## 44. Why use `inline` functions?

To avoid the runtime cost of creating function objects for lambdas, especially in hot code or higher-order functions called frequently. Also required for reified type parameters. Don't inline large functions — code bloat.

## 45. What are reified type parameters?

In an `inline` function, prefix a type parameter with `reified` to access it at runtime: `inline fun <reified T> isInstance(x: Any) = x is T`. Possible because the inline body is duplicated per call site with the concrete type.

## 46. What is a function type?

A type representing a function signature: `(Int, String) -> Boolean`. Values can be lambdas, function references (`::myFunc`), or objects implementing `FunctionN`. Function types can be nullable, suspend-marked, or have a receiver.

## 47. What are scope functions?

Standard library functions that execute a block in the context of an object: `let`, `run`, `with`, `apply`, `also`. They differ in how they refer to the context object (`it` vs `this`) and what they return (context object vs lambda result).

## 48. What is the difference between `let` and `also`?

`let` passes the object as `it` and returns the lambda result — useful for transformation and null checks. `also` passes the object as `it` and returns the object itself — useful for side effects like logging without breaking the chain.

## 49. What is the difference between `apply` and `also`?

Both return the receiver. `apply` exposes it as `this` (implicit receiver), good for property setting. `also` exposes it as `it`, good when you need the explicit name or when `this` would be ambiguous.

## 50. What is the difference between `run` and `with`?

Both expose the receiver as `this` and return the lambda result. `run` is an extension (`obj.run { ... }`), works on nullables via `?.run`. `with` is a regular function (`with(obj) { ... }`), reads more naturally when the receiver is not optional.

## 51. What are coroutines?

A concurrency primitive that allows writing asynchronous code in a sequential style. A coroutine can suspend without blocking a thread, then resume later. Backed by continuation-passing transforms at compile time. Replaces callback hell and most thread-pool boilerplate.

## 52. What is `suspend`?

A modifier marking a function as suspendable — it can be paused and resumed. Can only be called from another suspend function or a coroutine builder. The compiler transforms suspend functions into state machines.

## 53. What is the difference between a coroutine and a thread?

A thread is an OS-level resource, expensive to create and switch. A coroutine is a language-level construct multiplexed onto threads — thousands can run on a small pool. Coroutines suspend cooperatively; threads are preempted.

## 54. What are coroutine builders?

Functions that create coroutines: `launch` (fire and forget, returns `Job`), `async` (returns `Deferred<T>` for a result), `runBlocking` (blocks the current thread until completion, mainly for tests/main). Builders run inside a `CoroutineScope`.

## 55. What is a `CoroutineScope`?

The lifetime owner for a group of coroutines. Cancelling the scope cancels all coroutines launched in it. Examples: `viewModelScope`, `lifecycleScope` on Android, `GlobalScope` (discouraged), and custom scopes built with `CoroutineScope(...)`.

## 56. What is a `CoroutineContext`?

A set of elements configuring a coroutine: dispatcher, job, name, exception handler. Combined with `+`. Inherited from the launching scope and overridable per builder. The dispatcher determines which thread the coroutine runs on.

## 57. What are coroutine dispatchers?

`Dispatchers.Main` runs on the main thread (UI). `Dispatchers.IO` is a pool sized for blocking I/O. `Dispatchers.Default` is a pool sized for CPU work. `Dispatchers.Unconfined` runs in the calling thread until the first suspension — rarely useful in production.

## 58. What is structured concurrency?

A discipline where every coroutine has a parent scope, and the parent waits for its children before completing. Cancellation propagates downward; failures propagate upward (by default). Prevents leaks and orphaned tasks.

## 59. What is the difference between `launch` and `async`?

`launch` returns a `Job` and is used for coroutines that don't return a value. `async` returns a `Deferred<T>` whose `await()` gives the result. Use `async` only when you need a result, otherwise `launch`.

## 60. What is `withContext`?

A suspending function that switches the coroutine's dispatcher for a block: `withContext(Dispatchers.IO) { ... }`. Returns the block's result. Used to perform blocking work off the main thread.

## 61. What is a `Job`?

A handle to a coroutine's lifecycle. Provides `cancel`, `join`, and state queries (`isActive`, `isCompleted`). Jobs form a parent-child hierarchy that enforces structured concurrency.

## 62. What is a `Deferred`?

A `Job` that produces a value. Created by `async`. Call `await()` to suspend until the result is ready. If the coroutine throws, `await` rethrows.

## 63. What is `Flow`?

A cold asynchronous stream of values. Built on coroutines and operates with suspension. Operators include `map`, `filter`, `collect`, `flatMapConcat`. Conceptually similar to RxJava `Observable` but coroutine-native.

## 64. What is the difference between cold and hot flows?

Cold flows (`flow { ... }`) start emitting only when collected; each collector gets its own emission stream. Hot flows (`SharedFlow`, `StateFlow`) emit independently of collectors and share emissions across all of them.

## 65. What is `StateFlow`?

A hot flow that always has a current value, conflates updates, and emits only when the value changes (by equality). Replaces `LiveData` in modern Android architecture. Has a `value` property for synchronous reads.

## 66. What is `SharedFlow`?

A hot flow configurable with replay cache and buffer. Doesn't have a "current value" concept. Use for events that fire over time (navigation, errors) where you don't want the new collector to get an old state.

## 67. What is the difference between `StateFlow` and `SharedFlow`?

`StateFlow` is a `SharedFlow` specialized for state: always one current value, conflated, distinct emissions. `SharedFlow` is more general — configurable replay, no current-value semantics. Use `StateFlow` for state, `SharedFlow` for events.

## 68. What is `LiveData`?

An Android-specific observable data holder that respects the lifecycle of observers, only delivering updates to active observers. Predates coroutines and is increasingly replaced by `StateFlow` + `repeatOnLifecycle`.

## 69. How do you cancel a coroutine?

Call `cancel()` on its `Job`. Cancellation is cooperative — the coroutine must reach a suspension point or check `isActive`/`ensureActive()` to respond. Most stdlib suspend functions are cancellation-aware.

## 70. What is exception handling in coroutines?

In `launch`, uncaught exceptions propagate up the scope and can be intercepted by a `CoroutineExceptionHandler`. In `async`, exceptions are stored in the `Deferred` and rethrown on `await`. `SupervisorJob` allows sibling coroutines to fail independently.

## 71. What is the difference between `Job` and `SupervisorJob`?

In a regular `Job`, a child failure cancels all siblings and the parent. With `SupervisorJob` (or `supervisorScope`), child failures don't cancel siblings. Use `SupervisorJob` for independent tasks (e.g., multiple network calls) where one failure shouldn't take down the rest.

## 72. What is `runBlocking`?

A bridge from regular code to coroutines that blocks the current thread until the coroutine completes. Use in `main` functions and tests; avoid in library or production async code because it defeats the point of coroutines.

## 73. What is interoperability with Java?

Kotlin compiles to JVM bytecode and can call Java seamlessly. Java can call most Kotlin code, though some features (extensions, suspend functions, default arguments) require workarounds. Annotations like `@JvmStatic`, `@JvmOverloads`, `@JvmName`, and `@JvmField` smooth the seams.

## 74. What does `@JvmStatic` do?

Generates a real Java static method for a companion-object or object method, so Java callers don't need to go through the `INSTANCE` or `Companion` field. Applies to methods and properties.

## 75. What does `@JvmOverloads` do?

For a function with default parameters, generates overloaded Java methods for each default. Without it, Java callers must pass every argument because Kotlin defaults aren't visible to Java.

## 76. What does `@JvmField` do?

Exposes a Kotlin property as a public Java field rather than a getter/setter pair. Useful for performance-sensitive constants or for Java frameworks that reflect on fields.

## 77. What are platform types?

Types coming from Java code where Kotlin can't determine nullability (no annotations). Written as `T!` in signatures. Treated permissively — you can use them as nullable or non-nullable — but NPEs at runtime are possible. Annotate Java code with `@Nullable`/`@NonNull` to fix.

## 78. What is type variance in Kotlin?

How a generic type relates to its type-parameter subtyping. `out T` (covariant) means the type produces `T` and can be used where a supertype's parametrization is expected. `in T` (contravariant) means it consumes `T`. Invariant by default.

## 79. What is the difference between `List<out T>` and `List<in T>`?

`List<out T>` (covariant) — a `List<String>` is a `List<out Any>`; you can read `Any` from it but not safely write. `List<in T>` (contravariant) — a `MutableList<Any>` is a `MutableList<in String>`; you can write `String` to it but reads come back as `Any?`.

## 80. What is a star projection (`*`)?

A wildcard for an unknown type argument: `List<*>` means "a list of something." You can read from it (as `Any?`) but not write. Used when you don't care about the specific type parameter.

## 81. What is the difference between `List` and `MutableList`?

`List<T>` exposes only read operations; `MutableList<T>` adds modification (`add`, `remove`, etc.). At runtime both are backed by `java.util.ArrayList` (or similar) — the distinction is enforced at compile time through interfaces.

## 82. What is the difference between `Array<Int>` and `IntArray`?

`Array<Int>` is a generic array of boxed `Integer` objects. `IntArray` is a primitive `int[]` with no boxing. Use primitive array types (`IntArray`, `DoubleArray`, etc.) for performance-sensitive code.

## 83. What are top-level functions?

Functions declared outside any class, at the package level. Common for utilities. On the JVM, they compile to static methods on a synthetic class (named `<File>Kt` by default, configurable with `@file:JvmName`).

## 84. What is the difference between `Sequence` and `Iterable`?

`Iterable` operations are eager — each operator produces an intermediate collection. `Sequence` operations are lazy — values flow through the pipeline one at a time, avoiding intermediate collections. Use `Sequence` for long chains on large data; `Iterable` for short chains.

## 85. What are operator functions?

Functions that overload operators by being declared with the `operator` keyword and a specific name: `plus` for `+`, `get` for `[]`, `invoke` for `()`. Enables custom DSLs and natural syntax on user-defined types.

## 86. What is an `infix` function?

A function callable without dot or parentheses: `1 to "one"` instead of `1.to("one")`. Must be a member or extension, take one parameter, and be marked `infix`. Useful for DSLs.

## 87. What is a `tailrec` function?

A recursive function the compiler converts into a loop, eliminating stack frames. Must be declared `tailrec` and have its recursive call as the last operation. Used for deep recursion without stack overflow.

## 88. What is a function reference?

A reference to a named function as a function-type value: `::println`, `String::length`, `instance::method`. Lets you pass functions where a lambda would normally go.

## 89. What is the difference between `==` and `equals()`?

In Kotlin, `==` translates to `equals()` with proper null handling: `a == b` becomes `a?.equals(b) ?: (b === null)`. So `==` is structural equality, equivalent to (and clearer than) calling `equals()` directly.

## 90. What is the difference between `Unit` and `void`?

`Unit` is Kotlin's equivalent of `void` but is an actual type with a single value (`Unit`). Functions that don't declare a return type return `Unit` implicitly. Useful in generic contexts where `void` can't appear.

## 91. What is the `Nothing` type?

The type with no instances. The return type of functions that never return normally (always throw or loop forever): `throw`, `error()`, `TODO()`. `Nothing` is a subtype of every type, so it can appear anywhere.

## 92. What is `TODO()` in Kotlin?

A standard library function that always throws `NotImplementedError`. Has return type `Nothing`, so it satisfies any expected return type. Use as a placeholder during development.

## 93. What is the Kotlin standard library?

A set of utilities shipped with the language: collections operations, scope functions, ranges, sequences, text/IO helpers, coroutines core, and more. Always available without additional dependencies. Designed to make Java APIs feel idiomatic.

## 94. What is a range in Kotlin?

A sequence of values produced by `..`, `until`, `downTo`, `step`. `1..10` is an inclusive range; `1 until 10` excludes the upper bound; `10 downTo 1` counts backward. Ranges are iterable and support `in` checks.

## 95. What is the difference between `..` and `until`?

`1..10` includes both endpoints (1 through 10). `1 until 10` excludes the upper endpoint (1 through 9). `until` is the more correct choice when iterating up to a size (`0 until list.size`).

## 96. What is a type alias?

A name for an existing type: `typealias UserMap = Map<UserId, User>`. Doesn't create a new type; the alias is interchangeable with the underlying type. Useful for shortening long generic types or function types.

## 97. What is an inline class (value class)?

A class with a single property that the compiler erases at runtime in most contexts, avoiding allocation. Declared with `@JvmInline value class`. Used for type-safe primitives like `value class UserId(val raw: Long)` without boxing overhead.

## 98. What is the Kotlin Multiplatform Project (KMP)?

A way to share code across platforms — JVM, Android, iOS, JS, native — while writing platform-specific code where needed. `commonMain` holds shared code; `expect`/`actual` declarations bridge to per-platform implementations.

## 99. What is `expect`/`actual`?

The KMP mechanism for platform-specific implementations. `expect` declares an API in `commonMain`; each platform module provides an `actual` implementation. The compiler links them per target.

## 100. What is Kotlin DSL?

Kotlin's features (lambdas with receivers, infix functions, operator overloading, builders) make it well-suited to internal DSLs. Examples: Gradle Kotlin DSL, Jetpack Compose, Ktor routing, HTML builders. Replaces XML/JSON config with type-safe Kotlin code.
