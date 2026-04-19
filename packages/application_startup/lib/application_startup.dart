// ignore_for_file: public_member_api_docs

export 'src/public.dart';

/*
import 'dart:async' show FutureOr, TimeoutException;

import 'package:application_startup/src/errors.dart'
    show
        BlankServiceName,
        DuplicateServiceEntry,
        ServiceItemTimeout,
        ServiceNotReady,
        ServiceNotRegistered,
        ServiceRegistrationError,
        StartServiceError,
        UnknownServiceEntry;
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:get_it/get_it.dart' show GetIt;
import 'package:my_logger/my_logger.dart';

export '/src/public.dart';

abstract class BaseServiceStatus {
  const BaseServiceStatus(this.status);
  final ServiceItemStatus status;

  @override
  String toString() => 'Status: ${status.name}';
}

//-
sealed class ServiceStatus extends BaseServiceStatus {
  const ServiceStatus(super.status);
}

//-
final class ServicesEmpty extends ServiceStatus {
  ServicesEmpty() : super(.waiting);

  @override
  String toString() => 'No Services';
}

//-
final class LoadState<SRV extends ServiceClass> extends ServiceStatus {
  LoadState(this.serviceName, super.status) {
    MyLogger.i(toString(), tag: 'STT');
  }

  final String serviceName;

  @override
  String toString() => 'Load State: "$serviceName" Status: ${status.name}';
}

//-
final class RegisterService extends ServiceStatus {
  RegisterService({required this.name}) : super(.registering) {
    MyLogger.i(toString(), tag: 'STT');
  }
  final String name;

  @override
  String toString() => 'RegisterService "$name"';
}

final class RegisterStatus<SRV extends ServiceClass> extends ServiceStatus {
  RegisterStatus(super.status, {required this.name}) {
    MyLogger.i(toString(), tag: 'STT');
  }

  final String name;

  @override
  String toString() => 'registering status for "$name" : ${status.name}';
}

//-
final class StartingService extends ServiceStatus {
  StartingService({required this.name}) : super(.starting) {
    MyLogger.i(toString(), tag: 'STT');
  }
  final String name;

  @override
  String toString() => 'Starting Service "$name"';
}

//-
final class ServiceReady<SRV extends ServiceClass> extends ServiceStatus {
  ServiceReady(super.status, {required this.name, required this.service}) {
    MyLogger.i(toString(), tag: 'RDY');
  }

  final String name;
  final SRV service;

  @override
  String toString() => '"$name" status: ${status.name} service: $service}';
}

// ----------------------------------------------------------------------------
typedef SrvcsBroker = ServicesLocatorBroker;

class ServicesLocatorBroker {
  static const String _name = 'ServicesLocatorBroker';

  /// [_name] is easier to change at the top of the class
  // ignore: sort_constructors_first
  ServicesLocatorBroker._() {
    final cubit = ServicesLocatorCubit(using: GetItServiceProvider.P);
    GetIt.I.registerSingleton<ServicesLocatorCubit>(
      cubit,
      instanceName: _name,
      signalsReady: true,
    );
  }

  static ServicesLocatorCubit get L {
    if (!GetIt.I.isRegistered<ServicesLocatorCubit>(instanceName: _name)) {
      ServicesLocatorBroker._();
    }
    return GetIt.I.get<ServicesLocatorCubit>(instanceName: _name);
  }
}

// ----------------------------------------------------------------------------
class ServicesLocatorCubit extends Cubit<ServiceStatus> {
  ServicesLocatorCubit({required BaseServiceProvider using})
    : provider = using,
      super(ServicesEmpty());

  final BaseServiceProvider provider;

  void load<SRV extends ServiceClass>(BaseServiceItem<SRV> serviceItem) {
    provider.load<SRV>(serviceItem);
    emit(LoadState<SRV>(serviceItem.name, serviceItem.status));
  }

  Future<void> register<SRV extends ServiceClass>(
    String name,
  ) async {
    await provider.register<SRV>(
      name,
      onServiceRegister: (name, status) {
        emit(RegisterStatus(status, name: name));
      },
    );
  }

  //-
  Future<void> start<SRV extends ServiceClass>(String name) async {
    emit(StartingService(name: name));
    final service = await provider.startServiceAsync<SRV>(name);
    emit(ServiceReady(.ready, name: name, service: service));
  }
}

//------------------------------------------------------------------------------

typedef OnServiceRegister<SRV extends ServiceClass> =
    void Function(
      String name,
      ServiceItemStatus status,
    );

typedef OnServiceReady<SRV extends ServiceClass> =
    void Function(
      String name,
      SRV service,
    );

typedef OnServiceStart<SRV extends ServiceClass> = OnServiceRegister<SRV>;

//-
class GetItServiceLocator extends BaseServiceLocator {
  static const Duration defaultDuration = Duration(hours: 1);

  //+ GET
  @override
  Future<SRV> getServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    if (!GetIt.I.isRegistered<SRV>(instanceName: name)) {
      throw ServiceNotRegistered(name);
    }
    await GetIt.I.isReady<SRV>(instanceName: name, timeout: timeout);
    return GetIt.I.get<SRV>(instanceName: name);
  }

  @override
  SRV getServiceSync<SRV extends ServiceClass>({required String name}) {
    if (!GetIt.I.isRegistered<SRV>(instanceName: name)) {
      throw ServiceNotRegistered(name);
    }
    try {
      return GetIt.I.get<SRV>(instanceName: name);

      /// 'on Error' is a documented exception in the GetIt API
      // ignore: avoid_catching_errors
    } on Error {
      throw ServiceNotReady(name);
    }
  }

  //+ REGISTER
  @override
  void registerServiceLazyAsync<SRV extends ServiceClass>({
    required String name,
    required Future<SRV> Function() factory,
    required OnServiceReady<SRV> onServiceReady,
    required OnServiceRegister onServiceRegister,
  }) {
    if (GetIt.I.isRegistered<SRV>(instanceName: name)) return;

    GetIt.I.registerLazySingletonAsync<SRV>(
      factory,
      instanceName: name,
      onCreated: (service) {
        MyLogger.t('Service Ready: $name');
        onServiceReady.call(name, service);
      },
    );

    MyLogger.t('Service Registering: $name');
    onServiceRegister.call(name, .registering);
  }

  @override
  SRV registerServiceSync<SRV extends ServiceClass>({
    required String name,
    required SRV instance,
  }) {
    if (GetIt.I.isRegistered<SRV>(instanceName: name)) {
      throw DuplicateServiceEntry(name);
    }

    return GetIt.I.registerSingleton<SRV>(
      instance,
      instanceName: name,
      signalsReady: true,
    );
  }

  @override
  Future<SRV> startServiceAsync<SRV extends ServiceClass>({
    required String name,
    required Duration timeout,
  }) async {
    if (!GetIt.I.isRegistered<SRV>(instanceName: name)) {
      throw ServiceNotRegistered(name);
    }
    return GetIt.I.getAsync<SRV>(instanceName: name).timeout(timeout);
  }
}

// ----------------------------------------------------------------------------
abstract class BaseServiceProvider {
  //+ LOAD
  void load<SRV extends ServiceClass>(BaseServiceItem<SRV> serviceItem);

  //+ REGISTER
  Future<void> register<SRV extends ServiceClass>(
    String name, {
    required OnServiceRegister onServiceRegister,
  });

  //+ START
  Future<SRV> startServiceAsync<SRV extends ServiceClass>(String name);
}

abstract class BaseServiceProvider {
  //+ LOAD
  void load<SRV extends ServiceClass>(BaseServiceItem<SRV> serviceItem);

  //+ REGISTER
  Future<void> register<SRV extends ServiceClass>(
    String name, {
    required OnServiceReady<SRV> onServiceReady,
    required OnServiceRegister onServiceRegister,
  });

  //+ START
  Future<SRV> startServiceAsync<SRV extends ServiceClass>(String name);
}

//-
class GetItServiceProvider extends BaseServiceProvider {
  GetItServiceProvider._();

  final GetItServiceLocator _serviceLocator = GetItServiceLocator();

  static final GetItServiceProvider _instance = GetItServiceProvider._();
  static GetItServiceProvider get P => _instance;

  final Map<String, BaseServiceItem> _providers = {};

  @override
  void load<SRV extends ServiceClass>(
    BaseServiceItem<SRV> serviceItem,
  ) {
    if (serviceItem.name.trim().isEmpty) {
      throw BlankServiceName();
    }
    if (_providers[serviceItem.name] != null) {
      throw DuplicateServiceEntry(serviceItem.name);
    }
    _providers[serviceItem.name] = serviceItem;
    serviceItem.status = .loaded;
  }

  @override
  Future<void> register<SRV extends ServiceClass>(
    String name, {
    required OnServiceReady<SRV> onServiceReady,
    required OnServiceRegister onServiceRegister,
  }) async {
    final serviceItem = _getServiceItem(name) as BaseServiceItem<SRV>;
    MyLogger.t('Registering $serviceItem}', tag: '?');

    switch (serviceItem.status) {
      case ServiceItemStatus.loaded:
        break;

      case ServiceItemStatus.ready:
        try {
          final service = _serviceLocator.getServiceSync<SRV>(name: name);
          onServiceReady.call(name, service);
        } catch (e) {
          throw ServiceRegistrationError(name, cause: e);
        }
        return;

      case ServiceItemStatus.registered:
      case ServiceItemStatus.registering:
        onServiceRegister.call(name, serviceItem.status);
        return;

      case ServiceItemStatus.starting:
      case ServiceItemStatus.waiting:
        throw ServiceRegistrationError(
          name,
          cause: 'invalid state "${serviceItem.status.name}"',
        );
    }

    // Make sure dependencies are registered
    try {
      await Future.wait(
        serviceItem.dependencies.map((dependant) async {
          final service = _getServiceItem(dependant);
          if (service.status == .loaded) {
            MyLogger.t('Registering dependency: "${service.name}"');
            await service.registerService();
          }
        }),
      ).timeout(serviceItem.timeout);
    } on TimeoutException {
      throw ServiceItemTimeout(name, serviceItem.timeout);
    }

    switch (serviceItem.registerType) {
      case ServiceRegisterType.singletonSync:
        try {
          final service = _serviceLocator.registerServiceSync<SRV>(
            name: name,
            instance: await serviceItem.factory().timeout(serviceItem.timeout),
          );
          serviceItem.status = .ready;
          onServiceReady.call(name, service);
        } on TimeoutException {
          throw ServiceItemTimeout(name, serviceItem.timeout);
        } catch (e) {
          throw ServiceRegistrationError(name, cause: e);
        }

      case ServiceRegisterType.lazySingletonAsync:
        _serviceLocator.registerServiceLazyAsync(
          name: name,
          factory: serviceItem.factory,
          onServiceReady: (name, service) {
            serviceItem.status = .ready;
            onServiceReady.call(name, service);
          },
          onServiceRegister: (name, status) {
            serviceItem.status = status;
            onServiceRegister.call(name, status);
          },
        );
    }
  }

  @override
  Future<SRV> startServiceAsync<SRV extends ServiceClass>(String name) async {
    final serviceItem = _getServiceItem(name) as BaseServiceItem<SRV>;
    MyLogger.t('startServiceAsync: Starting Service "$name"', tag: 'sSA');

    switch (serviceItem.status) {
      case ServiceItemStatus.loaded:
        throw ServiceNotRegistered(name);

      case ServiceItemStatus.ready:
        try {
          return _serviceLocator.getServiceSync<SRV>(name: name);
        } on Exception catch (e) {
          throw ServiceRegistrationError(name, cause: e);
        }

      case ServiceItemStatus.registering:
      case ServiceItemStatus.registered:
        break;

      case ServiceItemStatus.starting:
      case ServiceItemStatus.waiting:
        throw StartServiceError(
          name,
          reason: 'Invalid status "${serviceItem.status.name}"',
        );
    }

    // Start dependencies
    try {
      await Future.wait(
        serviceItem.dependencies.map(
          (dependant) async {
            final svc = _getServiceItem(dependant);
            MyLogger.i('Dependency: $svc', tag: '🏷️');
            if (svc.status != .ready) {
              MyLogger.d('Doing start on: $svc', tag: '🏃‍♂️');
              await svc.startService();
            }
          },
        ),
      ).timeout(serviceItem.timeout);
      MyLogger.i('Dependices Check complete', tag: '🏁');
    } on TimeoutException {
      throw ServiceItemTimeout(name, serviceItem.timeout);
    }

    try {
      // Will update the status of any lazy-services
      final service = await _serviceLocator.getServiceAsync<SRV>(
        name: serviceItem.name,
        timeout: serviceItem.timeout,
      );

      return service;
    } on TimeoutException {
      throw ServiceItemTimeout(serviceItem.name, serviceItem.timeout);
    } catch (e) {
      throw StartServiceError(name, reason: e.toString());
    }
  }

  BaseServiceItem _getServiceItem(String name) {
    if (name.trim().isEmpty) throw BlankServiceName();
    final serviceItem = _providers[name];
    if (serviceItem == null) throw UnknownServiceEntry(name);
    return serviceItem;
  }
}

// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------

abstract class BaseServiceItem<SRV extends ServiceClass>
    implements ServiceClass {
  String get name;

  ServiceItemStatus get status => .waiting;
  set status(ServiceItemStatus value);

  Future<SRV> Function() get factory;

  Duration get timeout => BaseServiceLocator.defaultDuration;

  List<String> get dependencies => [];

  ServiceRegisterType get registerType;

  FutureOr<void> registerService() => SrvcsBroker.L.register<SRV>(name);

  FutureOr<void> startService() => SrvcsBroker.L.start<SRV>(name);

  @override
  String toString() => 'Name: "$name" Status: ${status.name}';
}

//-----
class ThemeServiceItem extends BaseServiceItem<ThemeService> {
  @override
  final String name = 'ThemeService';

  @override
  ServiceItemStatus status = .waiting;

  @override
  Future<ThemeService> Function() get factory =>
      () async => ThemeService();

  @override
  final ServiceRegisterType registerType = .singletonSync;
}

class ThemeService implements ServiceClass {}

class ChuckleServiceItem extends BaseServiceItem<ChuckleService> {
  @override
  final String name = 'ChuckleService';

  @override
  ServiceItemStatus status = .waiting;

  @override
  Future<ChuckleService> Function() get factory =>
      () async => ChuckleService();

  @override
  final ServiceRegisterType registerType = .lazySingletonAsync;
}

class ChuckleService implements ServiceClass {}

//------------------------------------------------------------------------------
*/
