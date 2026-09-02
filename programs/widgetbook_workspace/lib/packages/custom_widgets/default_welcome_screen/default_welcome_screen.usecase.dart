// programs/widgetbook_workspace/lib/packages/custom_widgets/default_welcome_screen/default_welcome_screen.usecase.dart
// ignore_for_file: public_member_api_docs
import 'package:custom_widgets/custom_widgets.dart' show DefaultWelcomeScreen;
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: DefaultWelcomeScreen)
Widget buildDefaultWelcomeScreenUseCase(BuildContext context) {
  // DefaultWelcomeScreen takes no parameters, so the use case has no
  // knobs; viewport and theme variation come from the workbench addons.
  return const DefaultWelcomeScreen();
}
