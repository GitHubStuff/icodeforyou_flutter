// packages/services_locator/test/src/service_locator_registry/service_registration_test.dart
//
// Unit tests for [ServiceRegistration]. No mocks required — the class is
// pure state. Tests are structured by public member so coverage gaps are
// easy to spot in the group structure.

// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/src/errors.dart' show ServiceStartupFailed;
import 'package:service_locator/src/locator_status.dart' show LocatorStatus;
import 'package:service_locator/src/service_descriptor/service_descriptor.dart'
    show ServiceClass, SyncServiceDescriptor;
import 'package:service_locator/src/service_registry/service_registration.dart'
    show ServiceRegistration;

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

abstract interface class _WidgetService implements ServiceClass {}

class _FakeWidget implements _WidgetService {
  const _FakeWidget([this.tag = 'default']);
  final String tag;

  @override
  String toString() => 'FakeWidget($tag)';
}

/// Minimal [SyncServiceDescriptor] — the tests never invoke `registerWith`,
/// so the inherited body and unused `builder` are safe. `ServiceDescriptor`
/// is sealed; extending a concrete subclass is required.
class _FakeDescriptor extends SyncServiceDescriptor<_WidgetService> {
  const _FakeDescriptor({this.descriptorName = 'widget'});

  final String descriptorName;

  @override
  String get name => descriptorName;

  @override
  _WidgetService Function() get builder => _FakeWidget.new;
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

ServiceRegistration<_WidgetService> _fresh({String name = 'widget'}) =>
    ServiceRegistration<_WidgetService>(_FakeDescriptor(descriptorName: name));

void main() {
  // =========================================================================
  // Construction & initial state
  // =========================================================================

  group('initial state', () {
    test('starts in staged status', () {
      expect(_fresh().status, LocatorStatus.staged);
    });

    test('instance, error, stackTrace, pendingStart are all null', () {
      final reg = _fresh();
      expect(reg.instance, isNull);
      expect(reg.error, isNull);
      expect(reg.stackTrace, isNull);
      expect(reg.pendingStart, isNull);
    });

    test('name is forwarded from the descriptor', () {
      expect(_fresh(name: 'custom-name').name, 'custom-name');
    });

    test('descriptor is exposed directly', () {
      const descriptor = _FakeDescriptor(descriptorName: 'exposed');
      final reg = ServiceRegistration<_WidgetService>(descriptor);
      expect(reg.descriptor, same(descriptor));
    });

    test('isStaged is true; other flags are false', () {
      final reg = _fresh();
      expect(reg.isStaged, isTrue);
      expect(reg.isStarting, isFalse);
      expect(reg.isReady, isFalse);
      expect(reg.isFailed, isFalse);
    });
  });

  // =========================================================================
  // markStarting
  // =========================================================================

  group('markStarting', () {
    test('transitions status to starting', () {
      final reg = _fresh();
      reg.markStarting(Future<void>.value());
      expect(reg.status, LocatorStatus.starting);
    });

    test('captures the pending future', () {
      final reg = _fresh();
      final pending = Future<void>.value();
      reg.markStarting(pending);
      expect(reg.pendingStart, same(pending));
    });

    test('isStarting is true; other flags are false', () {
      final reg = _fresh()..markStarting(Future<void>.value());
      expect(reg.isStarting, isTrue);
      expect(reg.isStaged, isFalse);
      expect(reg.isReady, isFalse);
      expect(reg.isFailed, isFalse);
    });
  });

  // =========================================================================
  // markReady
  // =========================================================================

  group('markReady', () {
    test('transitions status to ready', () {
      final reg = _fresh();
      reg.markReadyXXX(const _FakeWidget());
      expect(reg.status, LocatorStatus.ready);
    });

    test('stores the instance', () {
      final reg = _fresh();
      const widget = _FakeWidget('ready');
      reg.markReadyXXX(widget);
      expect(reg.instance, same(widget));
    });

    test('clears error and stackTrace when called after markFailed', () {
      // This test exists specifically to cover the `_error = null;` and
      // `_stackTrace = null;` lines inside markReady. Without going
      // failed → ready, those assignments are executed but their effect
      // is never observed by any other test.
      final reg = _fresh()
        ..markFailed(Exception('boom'), StackTrace.current)
        ..markReadyXXX(const _FakeWidget('recovered'));

      expect(reg.error, isNull);
      expect(reg.stackTrace, isNull);
      expect(reg.isFailed, isFalse);
      expect(reg.isReady, isTrue);
    });

    test('isReady is true; other flags are false', () {
      final reg = _fresh()..markReadyXXX(const _FakeWidget());
      expect(reg.isReady, isTrue);
      expect(reg.isStaged, isFalse);
      expect(reg.isStarting, isFalse);
      expect(reg.isFailed, isFalse);
    });
  });

  // =========================================================================
  // markFailed
  // =========================================================================

  group('markFailed', () {
    test('transitions status to failed', () {
      final reg = _fresh();
      reg.markFailed(Exception('boom'), StackTrace.current);
      expect(reg.status, LocatorStatus.failed);
    });

    test('stores error and stackTrace', () {
      final reg = _fresh();
      final error = Exception('boom');
      final trace = StackTrace.current;
      reg.markFailed(error, trace);
      expect(reg.error, same(error));
      expect(reg.stackTrace, same(trace));
    });

    test('isFailed is true; other flags are false', () {
      final reg = _fresh()..markFailed(Exception('boom'), StackTrace.current);
      expect(reg.isFailed, isTrue);
      expect(reg.isStaged, isFalse);
      expect(reg.isStarting, isFalse);
      expect(reg.isReady, isFalse);
    });
  });

  // =========================================================================
  // asStartupFailed
  // =========================================================================

  group('asStartupFailed', () {
    test('returns ServiceStartupFailed when status is failed', () {
      final error = Exception('boom');
      final trace = StackTrace.current;
      final reg = _fresh()..markFailed(error, trace);

      final result = reg.asStartupFailed();

      expect(result, isA<ServiceStartupFailed>());
      expect(result.serviceName, reg.name);
      expect(result.cause, same(error));
      expect(result.causeStackTrace, same(trace));
    });

    test('throws StateError when status is staged', () {
      final reg = _fresh();
      expect(
        reg.asStartupFailed,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains(reg.name),
              contains(LocatorStatus.staged.name),
              contains(LocatorStatus.failed.name),
            ),
          ),
        ),
      );
    });

    test('throws StateError when status is starting', () {
      final reg = _fresh()..markStarting(Future<void>.value());
      expect(reg.asStartupFailed, throwsStateError);
    });

    test('throws StateError when status is ready', () {
      final reg = _fresh()..markReadyXXX(const _FakeWidget());
      expect(reg.asStartupFailed, throwsStateError);
    });
  });

  // =========================================================================
  // toString — four combinations of the two conditional branches
  // =========================================================================

  group('toString', () {
    test('staged registration: base form, no markers', () {
      final out = _fresh(name: 'bare').toString();
      expect(out, 'bare [staged]');
    });

    test('ready registration: appends ✓ marker', () {
      final out = (_fresh(
        name: 'done',
      )..markReadyXXX(const _FakeWidget())).toString();
      expect(out, 'done [ready] ✓');
    });

    test('failed registration: appends ✗ marker with error', () {
      final out = (_fresh(
        name: 'broken',
      )..markFailed(Exception('boom'), StackTrace.current)).toString();
      expect(out, contains('broken [failed]'));
      expect(out, contains('✗'));
      expect(out, contains('boom'));
    });

    test('registration with both instance and error: both markers', () {
      // Achievable by marking ready then failed — markFailed does not
      // clear the prior instance. Covers the case where both `if` arms
      // in toString evaluate true.
      final reg = _fresh(name: 'mixed')
        ..markReadyXXX(const _FakeWidget())
        ..markFailed(Exception('late-boom'), StackTrace.current);

      final out = reg.toString();
      expect(out, contains('mixed [failed]'));
      expect(out, contains('✓'));
      expect(out, contains('✗'));
      expect(out, contains('late-boom'));
    });
  });

  // =========================================================================
  // Status getters (isStaged / isStarting / isReady / isFailed) —
  // exhaustive matrix. Each flag must return true in its own state and
  // false in every other state to cover the `==` branch in both directions.
  // =========================================================================

  group('status flag getters — exhaustive matrix', () {
    test('all four flags report correctly for each status', () {
      final staged = _fresh();
      final starting = _fresh()..markStarting(Future<void>.value());
      final ready = _fresh()..markReadyXXX(const _FakeWidget());
      final failed = _fresh()
        ..markFailed(Exception('boom'), StackTrace.current);

      // Row = status under test, column = flag being queried.
      expect(staged.isStaged, isTrue);
      expect(staged.isStarting, isFalse);
      expect(staged.isReady, isFalse);
      expect(staged.isFailed, isFalse);

      expect(starting.isStaged, isFalse);
      expect(starting.isStarting, isTrue);
      expect(starting.isReady, isFalse);
      expect(starting.isFailed, isFalse);

      expect(ready.isStaged, isFalse);
      expect(ready.isStarting, isFalse);
      expect(ready.isReady, isTrue);
      expect(ready.isFailed, isFalse);

      expect(failed.isStaged, isFalse);
      expect(failed.isStarting, isFalse);
      expect(failed.isReady, isFalse);
      expect(failed.isFailed, isTrue);
    });
  });
}
