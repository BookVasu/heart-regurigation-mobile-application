import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HeartSplashScreen(),
    );
  }
}

class HeartSplashScreen extends StatefulWidget {
  const HeartSplashScreen({super.key});

  @override
  State<HeartSplashScreen> createState() => _HeartSplashScreenState();
}

class _HeartSplashScreenState extends State<HeartSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _angle;


  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();


    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _angle = Tween<double>(begin: -0.36, end: 0.36).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );

    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_cTop, _cMid, _cNearWhite, _cWhite],
            stops: [0.0, 0.45, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 7),

              Center(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  child: Image.asset(
                    'asset/heart_icon_logo.png',
                    width: 110 * 3,
                    height: 110 * 3,
                    fit: BoxFit.contain,
                  ),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _angle.value,
                      child: child,
                    );
                  },
                ),
              ),

              const Spacer(flex: 7),

              Column(
                children: [
                  Container(
                    width: 400,
                    height: 1,
                    color: const Color(0xFFBDBDBD).withOpacity(0.35),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '2nd development',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFFBDBDBD),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
