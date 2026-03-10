// lib/packages/theme_package/theme_package.usecase.dart

import 'package:flutter/material.dart';
import 'package:theme_package/theme_package.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Default',
  type: ThemeSelectorWidget,
)
Widget buildThemeSelectorWidgetUseCase(BuildContext context) {
  return _ThemePackageUseCaseWrapper(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Theme Selector'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: ThemeSelectorWidget(),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Default',
  type: ThemeBuilder,
)
Widget buildThemeBuilderUseCase(BuildContext context) {
  return _ThemePackageUseCaseWrapper(
    child: ThemeBuilder(
      builder: (context, themeMode) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Theme Builder Demo'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current ThemeMode: ${themeMode.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                const ThemeSelectorWidget(),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  'Sample UI Elements',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated Button'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined Button'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Sample TextField',
                    hintText: 'Enter text...',
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Sample Switch'),
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

@widgetbook.UseCase(
  name: 'In Settings Page',
  type: ThemeSelectorWidget,
)
Widget buildThemeSelectorInSettingsUseCase(BuildContext context) {
  return _ThemePackageUseCaseWrapper(
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const ThemeSelectorWidget(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}

/// Wrapper widget that initializes ThemePackage for use cases.
///
/// Uses in-memory storage to avoid path_provider dependency
/// in Widgetbook environment.
class _ThemePackageUseCaseWrapper extends StatelessWidget {
  const _ThemePackageUseCaseWrapper({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ThemePackageRoot(
      databaseName: 'widgetbook_theme_db_',
      inMemory: true,
      splash: const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      child: ThemeBuilder(
        builder: (context, themeMode) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: themeMode,
            home: child,
          );
        },
      ),
    );
  }
}
