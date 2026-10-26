// packages/{{name.snakeCase()}}/example/{{name.snakeCase()}}_example.dart
// ignore_for_file: avoid_print
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';

void main() {
  final awesome = {{#pascalCase}}{{{name}}}{{/pascalCase}}();
  print('awesome?: ${awesome.isAwesome}');
}
