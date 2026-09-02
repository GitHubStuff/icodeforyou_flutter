# turn black_velet into an app

Using black_velet as a mason-brick, you get a complete rail-based navigation app.

There are serveral steps to 'make it your own'

## main.dart

There are a few 'TODO:' noted in the app that require attention.

### Service Provider
A service provider (e.g. 'get_it' package) can be defined/used.

These are the options:
  - InMemoryDependencyResolver() => uses Map<> and is pretty limited but good for testing
  - GetItDependencyResolver() => use GetIt as a backend and is more feature complete
  - null => No service provider, if your code never needs register a service or use "context.read<DependencyResolver>()", just pass null

### Background tasks

If there are tasks to run in the background at startup (e.g. database setup, network connections, polling, etc) they can be added
to:
```txt
   List<Future<void> Function()> tasks = [...]
```

This list of Future<void> methods are run while the splash screen is displayed/animating.


