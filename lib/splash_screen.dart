// splash_screen.dart

import 'package:flutter/material.dart';
import 'main.dart'; // Import MainPage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _backgroundOpacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Fade in background
    setState(() {
      _backgroundOpacity = 1.0;
    });
    await Future.delayed(const Duration(seconds: 1));

    // Fade in text
    setState(() {
      _textOpacity = 1.0;
    });
    await Future.delayed(const Duration(seconds: 2));

    // Fade out both background and text, then transition to MainPage
    setState(() {
      _backgroundOpacity = 0.0;
      _textOpacity = 0.0;
    });
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated background
          AnimatedOpacity(
            opacity: _backgroundOpacity,
            duration: const Duration(seconds: 1),
            child: Container(color: Colors.blueAccent),
          ),
          // Animated text
          Center(
            child: AnimatedOpacity(
              opacity: _textOpacity,
              duration: const Duration(seconds: 1),
              child: const Text(
                "Hello! How can you become more productive today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
