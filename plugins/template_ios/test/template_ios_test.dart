// plugins/template_ios/test/template_ios_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart'
    show MockPlatformInterfaceMixin;
import 'package:template_ios/template_ios.dart' show TemplateIos;
import 'package:template_ios/template_ios_method_channel.dart'
    show MethodChannelTemplateIos;
import 'package:template_ios/template_ios_platform_interface.dart';

class MockTemplateIosPlatform
    with MockPlatformInterfaceMixin
    implements TemplateIosPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TemplateIosPlatform initialPlatform = TemplateIosPlatform.instance;

  test('$MethodChannelTemplateIos is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTemplateIos>());
  });

  test('getPlatformVersion', () async {
    final TemplateIos templateIosPlugin = TemplateIos();
    final MockTemplateIosPlatform fakePlatform = MockTemplateIosPlatform();
    TemplateIosPlatform.instance = fakePlatform;

    expect(await templateIosPlugin.getPlatformVersion(), '42');
  });
}
