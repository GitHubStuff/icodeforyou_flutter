// {{folder_source}}/{{name.snakeCase()}}/lib/src/{{name.snakeCase()}}.dart
{{#is_widget}}
import 'package:flutter/widgets.dart';

class {{name.pascalCase()}} extends StatelessWidget {
  const {{name.pascalCase()}}({super.key});

  @override
  Widget build(BuildContext context) => 
    const Center(child: Text('😊 YOU ARE AWESOME 👍🏼'));
}
{{/is_widget}}
{{^is_widget}}

class {{name.pascalCase()}} {
  ///
  bool get isAwesome => true;
}
{{/is_widget}}