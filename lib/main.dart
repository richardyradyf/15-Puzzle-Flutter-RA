import 'package:flutter/material.dart';

import 'controllers/settings_controller.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  final settings = SettingsController(storage);
  runApp(PuzzleApp(settings: settings));
}

class PuzzleApp extends StatelessWidget {
  const PuzzleApp({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: '15-Puzzle Flutter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.themeMode,
        home: SplashScreen(settings: settings),
      ),
    );
  }
}