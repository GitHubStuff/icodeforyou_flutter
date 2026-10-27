# Flutter tips - tricks - gotchas

## @immutable misuse

```dart
@immutable
abstract final class PLog {
  const PLog();
  static void dp(String text) => debugPrint(text);
}
```

Legal, but meaningless — remove '**@immutable**'.

**@immutable** is a meta annotation that tells the analyzer *“every instance field of this class and its subclasses must be final”*. It only has something to check when instances exist. An ***abstract final class*** with only static members has no instance fields and can never be instantiated or extended, so there is nothing for the annotation to constrain. It compiles, the analyzer stays quiet, and it communicates a false expectation to the reader: that there are instances whose immutability matters.

Annotations should carry information. ***abstract final*** already says everything about this class.
