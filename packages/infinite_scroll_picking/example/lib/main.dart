import 'package:example/pick_manager_cubit.dart' show PickManagerCubit;
import 'package:example/showcase_page.dart' show ShowcasePage;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;

void main() => runApp(const ShowcaseApp());

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PickManagerCubit(),
      child: MaterialApp(
        title: 'Infinite Scroll Picker — Showcase',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ShowcasePage(),
      ),
    );
  }
}
