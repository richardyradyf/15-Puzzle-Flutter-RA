import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/settings_controller.dart';
import '../theme/app_theme.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.settings});

  final SettingsController settings;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  late final Animation<double> _scale = Tween(begin: 0.6, end: 1.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );

  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    if (widget.settings.animationsEnabled) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
    _timer = Timer(const Duration(seconds: 3), _goToMenu);
  }

  void _goToMenu() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: widget.settings.animDuration(500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            MenuScreen(settings: widget.settings),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: AppTheme.background(theme.colorScheme),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.grid_view_rounded,
                            size: 110, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(
                          '15-Puzzle Flutter',
                          style: theme.textTheme.headlineLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Universidad Metropolitana',
                            style: theme.textTheme.titleSmall),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: TextButton.icon(
                  onPressed: _goToMenu,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Saltar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}