import 'package:flutter_test/flutter_test.dart';
import 'package:berf/berf.dart';
import 'package:berf/berf_platform_interface.dart';
import 'package:berf/berf_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBerfPlatform
    with MockPlatformInterfaceMixin
    implements BerfPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BerfPlatform initialPlatform = BerfPlatform.instance;

  test('$MethodChannelBerf is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBerf>());
  });

  test('getPlatformVersion', () async {
    Berf berfPlugin = Berf();
    MockBerfPlatform fakePlatform = MockBerfPlatform();
    BerfPlatform.instance = fakePlatform;

    expect(await berfPlugin.getPlatformVersion(), '42');
  });
}
