// lib/main.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login.dart';
import 'signin.dart';
import 'loading.dart';
import 'register.dart';
import 'menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Lock portrait (remove portraitDown if you don’t want upside-down)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

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

            // ✅ add this button in login.dart (onSignIn)
            onSignIn: () => _goToSignIn(context),
          );
        },
      ),
    );
  }

  // --- FLOWS ---

  void _goToSignIn(BuildContext context) {
  // show loading first
  Navigator.of(context).push(_slideFade(const HeartSplashScreen()));

  final int ms = 300 + rng.nextInt(301); // 300..600
  Future.delayed(Duration(milliseconds: ms), () {
    if (!context.mounted) return;

    // replace loading with signin
    Navigator.of(context).pushReplacement(
      _slideFade(
        SignInScreen(
          onBack: () => Navigator.of(context).maybePop(),
          onLogin: (user, pass) {
            // TODO: auth later
            Navigator.of(context).pushReplacement(_slideFade(const MenuScreen()));
          },
        ),
      ),
    );
  });
}


  void _goToRegisterWithLoading(BuildContext context) {
    Navigator.of(context).push(_slideFade(const HeartSplashScreen()));

    final int ms = 300 + rng.nextInt(301); // 300..600
    Future.delayed(Duration(milliseconds: ms), () {
      if (!context.mounted) return;

      Navigator.of(context).pushReplacement(
        _slideFade(
          RegisterScreen(
            onBack: () => Navigator.of(context).maybePop(),
            onCreate: () {
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
