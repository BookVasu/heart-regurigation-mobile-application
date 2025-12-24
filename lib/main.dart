//hello world, code by Vasu Sricharoen
// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login.dart';
import 'loading.dart';
import 'register.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Use Builder so we have a context for Navigator in callbacks
      home: Builder(
        builder: (context) {
          return LoginScreen(
            onGetStarted: () => _goToRegisterWithLoading(context),
            onSignIn: () {
              // TODO: push your sign-in screen later
            },
          );
        },
      ),
    );
  }
}

final math.Random rng = math.Random();

void _goToRegisterWithLoading(BuildContext context) {
  Navigator.of(context).push(_slideFade(const HeartSplashScreen()));

  final int ms = 300 + rng.nextInt(301); // int: 300..600

  Future.delayed(Duration(milliseconds: ms), () {
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(_slideFade(const RegisterScreen()));
  });
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
