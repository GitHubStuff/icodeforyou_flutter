// lib/src/startup_splash_screen.dart

// ignore_for_file: document_ignores, public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:startup_package/src/cubit/startup_cubit.dart';

@protected
abstract class StartupSplashScreen extends StatefulWidget {
  const StartupSplashScreen({super.key});

  void signalAnimationComplete(BuildContext context) {
    context.read<StartupCubit>().signalAnimationComplete();
  }
}
