// packages/prism_bubble_widget/test/src/bubble_shader_manager_test.dart
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/bubble_shader_manager.dart';
import 'package:prism_bubble_widget/src/shader_load_exception.dart';

const _packagePrefix = 'packages/prism_bubble_widget/';
const _darkFile = 'shaders/bubble_dark.frag';
const _lightFile = 'shaders/bubble_light.frag';
const _packageDark = '$_packagePrefix$_darkFile';
const _packageLight = '$_packagePrefix$_lightFile';

final class _FakeAssetManifest implements AssetManifest {
  const _FakeAssetManifest(this._keys);

  final List<String> _keys;

  @override
  List<String> listAssets() => _keys;

  @override
  List<AssetMetadata>? getAssetVariants(String key) => null;
}

void _useManifest(List<String> keys) {
  BubbleShaderManager.manifestLoader = () async => _FakeAssetManifest(keys);
}

/// Records every key the manager asks for and serves the real program from
/// the bare key, so the success path still compiles a genuine shader.
List<String> _recordProgramRequests() {
  final requested = <String>[];
  BubbleShaderManager.programLoader = (key) {
    requested.add(key);
    return ui.FragmentProgram.fromAsset(key.replaceFirst(_packagePrefix, ''));
  };
  return requested;
}

Matcher _throwsShaderLoad(String messagePart) => throwsA(
  isA<ShaderLoadException>().having(
    (e) => e.message,
    'message',
    contains(messagePart),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BubbleShaderManager', () {
    late BubbleShaderManager manager;

    setUp(() {
      manager = BubbleShaderManager.instance;
      manager.resetForTesting();
    });

    tearDown(() => manager.resetForTesting());

    test('constants are correctly assigned', () {
      expect(BubbleShaderManager.uSizeXPos, 0);
      expect(BubbleShaderManager.uSizeYPos, 1);
      expect(BubbleShaderManager.uTintRPos, 2);
      expect(BubbleShaderManager.uTintGPos, 3);
      expect(BubbleShaderManager.uTintBPos, 4);
      expect(BubbleShaderManager.uTintAPPos, 5);
      expect(BubbleShaderManager.uArcOpacityPos, 6);
      expect(BubbleShaderManager.uDiffusionPos, 7);
      expect(BubbleShaderManager.uPhaseAnglePos, 8);
    });

    test('exposes a single shared instance', () {
      expect(BubbleShaderManager.instance, same(manager));
    });

    test('throws ShaderLoadException before init', () {
      expect(manager.isLoaded, isFalse);
      expect(
        () => manager.darkShader,
        _throwsShaderLoad('Dark bubble shader not loaded. Call init() first.'),
      );
      expect(
        () => manager.lightShader,
        _throwsShaderLoad('Light bubble shader not loaded. Call init() first.'),
      );
    });

    group('init', () {
      test(
        'loads from the real manifest and real assets, then short-circuits',
        () async {
          await manager.init();

          expect(manager.isLoaded, isTrue);
          expect(manager.darkShader, isA<ui.FragmentShader>());
          expect(manager.lightShader, isA<ui.FragmentShader>());

          // A second call must not touch the loaders at all.
          BubbleShaderManager.manifestLoader = () =>
              fail('manifest loaded again');
          BubbleShaderManager.programLoader = (_) =>
              fail('program loaded again');
          await manager.init();
          expect(manager.isLoaded, isTrue);
        },
      );

      test(
        'prefers the package-prefixed keys when the manifest lists them',
        () async {
          _useManifest([_packageDark, _packageLight, _darkFile, _lightFile]);
          final requested = _recordProgramRequests();

          await manager.init();

          expect(requested, [_packageDark, _packageLight]);
          expect(manager.isLoaded, isTrue);
        },
      );

      test('falls back to the bare keys when only those are listed', () async {
        _useManifest([_darkFile, _lightFile]);
        final requested = _recordProgramRequests();

        await manager.init();

        expect(requested, [_darkFile, _lightFile]);
        expect(manager.isLoaded, isTrue);
      });

      test('ignores unrelated manifest entries', () async {
        _useManifest(['assets/logo.png', _darkFile, 'fonts/x.ttf', _lightFile]);
        final requested = _recordProgramRequests();

        await manager.init();

        expect(requested, [_darkFile, _lightFile]);
      });

      test(
        'throws, without loading anything, when the dark shader is absent',
        () async {
          _useManifest([_lightFile]);
          final requested = _recordProgramRequests();

          await expectLater(
            manager.init(),
            _throwsShaderLoad(
              'Shader "$_darkFile" is not bundled: neither "$_packageDark" '
              'nor "$_darkFile" is present in the asset manifest.',
            ),
          );

          expect(requested, isEmpty);
          expect(manager.isLoaded, isFalse);
        },
      );

      test(
        'throws, without loading anything, when the light shader is absent',
        () async {
          _useManifest([_darkFile]);
          final requested = _recordProgramRequests();

          await expectLater(
            manager.init(),
            _throwsShaderLoad('Shader "$_lightFile" is not bundled'),
          );

          expect(requested, isEmpty);
          expect(manager.isLoaded, isFalse);
        },
      );

      test('throws when the manifest cannot be read', () async {
        BubbleShaderManager.manifestLoader = () async =>
            throw Exception('manifest unreadable');
        final requested = _recordProgramRequests();

        await expectLater(
          manager.init(),
          _throwsShaderLoad(
            'Failed to read the asset manifest: Exception: manifest unreadable',
          ),
        );

        expect(requested, isEmpty);
        expect(manager.isLoaded, isFalse);
      });

      test('wraps a program load failure and names the key', () async {
        _useManifest([_darkFile, _lightFile]);
        BubbleShaderManager.programLoader = (_) async =>
            throw Exception('Simulated asset failure');

        await expectLater(
          manager.init(),
          _throwsShaderLoad(
            'Failed to load bubble shader "$_darkFile": '
            'Exception: Simulated asset failure',
          ),
        );

        expect(manager.isLoaded, isFalse);
      });

      test(
        'assigns neither shader when only the second program fails',
        () async {
          _useManifest([_darkFile, _lightFile]);
          BubbleShaderManager.programLoader = (key) {
            if (key == _lightFile) {
              throw Exception('light failed');
            }
            return ui.FragmentProgram.fromAsset(key);
          };

          await expectLater(
            manager.init(),
            _throwsShaderLoad('Failed to load bubble shader "$_lightFile"'),
          );

          expect(manager.isLoaded, isFalse);
          expect(() => manager.darkShader, _throwsShaderLoad('not loaded'));
          expect(() => manager.lightShader, _throwsShaderLoad('not loaded'));
        },
      );
    });

    test('resetForTesting restores the real loaders', () async {
      _useManifest([]);
      BubbleShaderManager.programLoader = (_) => fail('fake loader');

      manager.resetForTesting();

      // With the real loaders restored, init succeeds against real assets.
      await manager.init();
      expect(manager.isLoaded, isTrue);
    });
  });
}
