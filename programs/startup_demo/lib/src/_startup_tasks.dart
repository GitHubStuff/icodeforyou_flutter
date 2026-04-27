// ignore_for_file: public_member_api_docs

class StartupTasks {
  const StartupTasks._();

  // static List<BaseServiceItem> get all => [
  //   //SinceWhenServiceItem(RootIsolateToken.instance!),
  // ];
}

/*
class SinceWhenServiceClass implements ServiceClass {
  SinceWhenServiceClass(this.db);
  final SinceWhenDatabase db;
}

class SinceWhenServiceItem extends BaseServiceItem<SinceWhenServiceClass> {
  @override
  final name = 'since_when';
  final RootIsolateToken _token = RootIsolateToken.instance!;

  @override
  final ServiceRegisterType registerType = .lazySingletonAsync;

  @override
  final Duration timeout = BaseServiceLocator.defaultDuration;

  @override
  ServiceItemStatus status = .waiting;

  @override
  Future<SinceWhenServiceClass> Function() get factory => () async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(_token);
    try {
      final result = await SinceWhenDatabase.open().timeout(timeout);
      final db = result.getOrElse((failure) => throw Exception(failure));
      return SinceWhenServiceClass(db);
    } on TimeoutException {
      throw ServiceItemTimeout(name, timeout);
    }
  };

  @override
  final List<String> dependencies = ['ThemeService','ChuckleService'];
}
*/
