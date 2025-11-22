import 'package:flutter/material.dart';
import 'package:splash_screen_package/splash_screen_package.dart';

// Global variable to control which scenario to demonstrate
enum DemoScenario { success, externalError, timeout }

DemoScenario currentScenario = DemoScenario.success;

void main() {
  runApp(const ScenarioSelector());
}

class ScenarioSelector extends StatelessWidget {
  const ScenarioSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ScenarioMenu(),
    );
  }
}

class ScenarioMenu extends StatelessWidget {
  const ScenarioMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splash Screen Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose a scenario to test:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                currentScenario = DemoScenario.success;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DemoApp(),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.green),
              label: const Text('Success Scenario'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                currentScenario = DemoScenario.externalError;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DemoApp(),
                  ),
                );
              },
              icon: const Icon(Icons.error, color: Colors.orange),
              label: const Text('External Error'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                currentScenario = DemoScenario.timeout;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DemoApp(),
                  ),
                );
              },
              icon: const Icon(Icons.timer_off, color: Colors.red),
              label: const Text('Timeout Error'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  @override
  void initState() {
    super.initState();
    // Initialize cubit based on scenario
    if (currentScenario == DemoScenario.timeout) {
      SplashScreenCubit.initialize(const Duration(seconds: 3));
    } else {
      SplashScreenCubit.initialize(const Duration(seconds: 30));
    }
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      switch (currentScenario) {
        case DemoScenario.success:
          // Simulate successful initialization
          await Future.delayed(const Duration(seconds: 2));
          SplashScreenCubit.instance.dismiss();
          break;

        case DemoScenario.externalError:
          // Simulate an external error during initialization
          await Future.delayed(const Duration(milliseconds: 1500));
          SplashScreenCubit.instance.reportError(
            const LoadingError(
              'Failed to connect to server',
              {
                'error_code': 'CONNECTION_FAILED',
                'server': 'api.example.com',
                'timestamp': '2025-11-08T12:34:56Z',
              },
            ),
          );
          break;

        case DemoScenario.timeout:
          // Do nothing - let the timeout trigger
          // The cubit will automatically report timeout error after 3 seconds
          break;
      }
    } catch (e) {
      SplashScreenCubit.instance.reportError(
        LoadingError(
          'Unexpected error',
          {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AppSplashScreen(
        animationWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterLogo(size: 200),
            SizedBox(height: 24),
            Text(
              'My Awesome App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        animationDuration: const Duration(seconds: 2),
        newRootWidget: const HomePage(),
        errorWidgetBuilder: (error) => ErrorScreen(
          errorMessage: error.errorMessage,
          errorDetails: error.errorDetails,
        ),
        timeoutDuration: currentScenario == DemoScenario.timeout
            ? const Duration(seconds: 3)
            : const Duration(seconds: 30),
        spinnerWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 4,
            ),
            SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        barrierColor: const Color(0x66FF9800),
        fadeInCurve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    SplashScreenCubit.reset();
    super.dispose();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'App Initialized Successfully!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'The splash screen has completed and the app is ready to use.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final Map<String, dynamic>? errorDetails;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'ERROR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              if (errorDetails != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Details:\n${errorDetails.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                ),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
