// packages/services_locator/lib/src/service_locator/mock_service_locator.dart
//
// A hand-rolled, GetIt-free implementation of [ServiceLocator] intended for
// unit tests, widget tests, and local development. Provides deterministic
// control over service readiness via [completeLazyService] and
// [failLazyService] test hooks, so tests never need to race against real
// async builders.
//
// ignore_for_file: public_member_api_docs

import 'dart:async' show Completer, TimeoutException, unawaited;

import 'package:services_locator/src/errors.dart'
    show DuplicateServiceEntry, ServiceNotReady, ServiceNotRegistered;
import 'package:services_locator/src/locator_status.dart' show LocatorStatus;
import 'package:services_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass;
import 'package:services_locator/src/service_locator/service_locator.dart'
    show ReportServiceState, ServiceLocator;

typedef _Key = ({Type type, String name});

class _Entry {
  _Entry.sync({required this.instance, required this.reportState})
    : completer = null,
      builder = null,
      isReady = true;

  _Entry.lazyAsync({
    required this.builder,
    required this.reportState,
  }) : instance = null,
       completer = Completer<Object>(),
       isReady = false;

  Object? instance;
  final Completer<Object>? completer;
  final Future<Object> Function()? builder;
  final ReportServiceState reportState;
  bool isReady;
  bool builderStarted = false;
}

class MockServiceLocator implements ServiceLocator {
  MockServiceLocator();

  final Map<_Key, _Entry> _entries = <_Key, _Entry>{};

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    final entry = _assertRegistered<SRV>(name);

    if (entry.isReady) return entry.instance! as SRV;

    // Kick the builder on first access, mirroring GetIt's lazy semantics.
    _maybeStartBuilder<SRV>(name: name, entry: entry);

    try {
      final instance = await entry.completer!.future.timeout(timeout);
      return instance as SRV;
    } on TimeoutException {
      throw ServiceNotReady(name, status: 'timeout after $timeout');
    }
  }

  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
    final entry = _assertRegistered<SRV>(name);
    if (!entry.isReady) {
      throw ServiceNotReady(name, status: 'sync get before ready');
    }
    return entry.instance! as SRV;
  }

  // ---------------------------------------------------------------------------
  // REGISTER
  // ---------------------------------------------------------------------------

  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() builder,
    required ReportServiceState serviceState,
  }) {
    final key = _keyOf<SRV>(name);
    if (_entries.containsKey(key)) throw DuplicateServiceEntry(name);

    _entries[key] = _Entry.lazyAsync(
      builder: () async => await builder() as Object,
      reportState: serviceState,
    );
    serviceState(LocatorStatus.starting);
  }

  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    final key = _keyOf<SRV>(name);
    if (_entries.containsKey(key)) throw DuplicateServiceEntry(name);

    _entries[key] = _Entry.sync(
      instance: instance,
      reportState: (_, {Object? instance}) {},
    );
    return instance;
  }

  // ---------------------------------------------------------------------------
  // Test hooks
  // ---------------------------------------------------------------------------

  /// Manually completes a lazy async service with [instance], firing the
  /// registered [ReportServiceState] with [LocatorStatus.ready]. Use this in
  /// tests when you want full control over when a service becomes available
  /// rather than relying on the registered builder.
  void completeLazyService<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    final entry = _assertRegistered<SRV>(name);
    if (entry.isReady) return;
    _markReady<SRV>(entry: entry, instance: instance);
  }

  /// Manually fails a lazy async service. Future awaiters will receive
  /// [error]. No-op if the service has already been completed (either by
  /// the builder or a prior hook call).
  void failLazyService<SRV extends ServiceClass>({
    required String name,
    required Object error,
  }) {
    final entry = _assertRegistered<SRV>(name);
    if (entry.isReady) return;
    if (entry.completer!.isCompleted) return;
    entry.completer!.completeError(error);
  }

  /// Clears every registration. Call from `tearDown` to isolate tests.
  void reset() => _entries.clear();

  /// Introspection helper for tests.
  bool isRegistered<SRV extends ServiceClass>({required String name}) =>
      _entries.containsKey(_keyOf<SRV>(name));

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  _Key _keyOf<SRV extends ServiceClass>(String name) => (type: SRV, name: name);

  _Entry _assertRegistered<SRV extends ServiceClass>(String name) {
    final entry = _entries[_keyOf<SRV>(name)];
    if (entry == null) throw ServiceNotRegistered(name);
    return entry;
  }

  void _maybeStartBuilder<SRV extends ServiceClass>({
    required String name,
    required _Entry entry,
  }) {
    if (entry.builderStarted) return;
    entry.builderStarted = true;

    Future<void> run() async {
      try {
        final built = await entry.builder!();
        // A test hook may have completed the entry while the builder was in
        // flight; in that case the injected instance wins and we drop the
        // builder's result.
        if (entry.isReady || entry.completer!.isCompleted) return;
        _markReady<SRV>(entry: entry, instance: built as SRV);
      } on Object catch (error) {
        // Same race: if the entry was already resolved by a hook, swallow
        // the builder error rather than crashing on a double-complete.
        if (entry.isReady || entry.completer!.isCompleted) return;
        entry.completer!.completeError(error);
      }
    }

    unawaited(run());
  }

  void _markReady<SRV extends ServiceClass>({
    required _Entry entry,
    required SRV instance,
  }) {
    entry
      ..instance = instance
      ..isReady = true;
    entry.completer!.complete(instance);
    entry.reportState(LocatorStatus.ready, instance: instance);
  }
}
