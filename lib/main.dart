// lib/main.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'login.dart';
import 'loading.dart';
import 'register.dart';
import 'menu.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final math.Random rng = math.Random();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return LoginScreen(
            onGetStarted: () => _goToRegisterWithLoading(context),
          );
        },
      ),
    );
  }

  void _goToRegisterWithLoading(BuildContext context) {
    // If your loading widget class is named LoadingScreen instead, swap it here.
    Navigator.of(context).push(_slideFade(const HeartSplashScreen()));

    final int ms = 300 + rng.nextInt(301); // 300..600
    Future.delayed(Duration(milliseconds: ms), () {
      if (!context.mounted) return;

      Navigator.of(context).pushReplacement(
        _slideFade(
          RegisterScreen(
            onBack: () => Navigator.of(context).maybePop(),
            onCreate: () {
              // go to menu after create
              Navigator.of(context).pushReplacement(_slideFade(const MenuScreen()));
            },
          ),
        ),
      );
    });
  }
}

PageRouteBuilder _slideFade(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(
        begin: const Offset(0.0, 0.03),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
