// lib/oops.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class OopsScreen extends StatefulWidget {
  const OopsScreen({
    super.key,
    this.onBackToMenu,
    this.heartAsset = 'asset/heart_icon_logo.png',
  });

  final VoidCallback? onBackToMenu;
  final String heartAsset;

  @override
  State<OopsScreen> createState() => _OopsScreenState();
}

class _OopsScreenState extends State<OopsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    final yAnim = Tween<double>(begin: 50, end: 0).animate(fade); // ✅ start lower, go up

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_cTop, _cMid, _cNearWhite, _cWhite],
            stops: [0.0, 0.48, 0.72, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // background icons
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.10,
                    child: Stack(
                      children: const [
                        _BgIcon(icon: Icons.favorite_rounded, left: 22, top: 90, size: 170, rot: -12),
                        _BgIcon(icon: Icons.local_hospital_rounded, left: 10, top: 190, size: 160, rot: 10),
                        _BgIcon(icon: Icons.description_rounded, right: 8, top: 40, size: 210, rot: 18),
                      ],
                    ),
                  ),
                ),
              ),

              // top row (back + menu)
              Positioned(
                left: 10,
                right: 10,
                top: 6,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ],
                ),
              ),

              // center content with entrance animation
              Center(
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, child) {
                    return Opacity(
                      opacity: fade.value, // ✅ invisible -> visible
                      child: Transform.translate(
                        offset: Offset(0, yAnim.value), // ✅ y: +50 -> 0
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          widget.heartAsset,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 18),

                        const Text(
                          'OOPS!',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          'This feature is in development\nPlease come back again soon!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // back to menu button
                        GestureDetector(
                          onTap: widget.onBackToMenu ?? () => Navigator.of(context).pop(),
                          child: Container(
                            height: 50,
                            width: 210,
                            decoration: BoxDecoration(
                              color: const Color(0xFF9A9CEC),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.16),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Back to Menu',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // footer line + text (optional like your other screens)
              Positioned(
                left: 26,
                right: 26,
                bottom: 14,
                child: Column(
                  children: [
                    Container(
                      height: 1,
                      color: const Color(0xFFBDBDBD).withOpacity(0.35),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '2MB development',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFBDBDBD),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BgIcon extends StatelessWidget {
  const _BgIcon({
    required this.icon,
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.rot,
  });

  final IconData icon;
  final double? left, right, top, bottom;
  final double size;
  final double rot;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: rot * math.pi / 180,
        child: Icon(icon, size: size, color: Colors.black),
      ),
    );
  }
}
