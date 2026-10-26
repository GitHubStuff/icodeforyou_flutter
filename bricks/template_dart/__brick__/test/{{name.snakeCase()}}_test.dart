// {{folder_source}}/{{name.snakeCase()}}/test/{{name.snakeCase()}}_test.dart
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';
import 'package:test/test.dart';

void main() {
  group('{{#pascalCase}}{{{name}}}{{/pascalCase}}', () {
    final awesome = {{#pascalCase}}{{{name}}}{{/pascalCase}}();

    test('isAwesome returns true', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}