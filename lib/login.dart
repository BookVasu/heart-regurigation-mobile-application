// lib/login.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onGetStarted,
    this.onSignIn,
    this.logoAsset = 'asset/login_logo.png',
    this.heartAsset = 'asset/heart_icon_logo.png',
  });

  final VoidCallback? onGetStarted;
  final VoidCallback? onSignIn;


  final String logoAsset;


  final String heartAsset;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {

  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  late final Ticker _ticker;
  final _rng = math.Random();

  // Particle config
  final int _count = 10;
  final List<_HeartParticle> _hearts = [];


  Duration _last = Duration.zero;


  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < _count; i++) {
      _hearts.add(_HeartParticle.random(_rng));
    }

    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration now) {
    final dt = (_last == Duration.zero) ? 0.016 : (now - _last).inMicroseconds / 1e6;
    _last = now;

    if (!mounted) return;


    if (_size == Size.zero) {
      setState(() {});
      return;
    }

    for (final h in _hearts) {
      h.y += h.speed * dt;
      h.rotation += h.rotSpeed * dt;

      // respawn when out of view
      if (h.y > _size.height + 120) {
        h.respawn(_rng, _size);
      }
    }

    setState(() {});
  }

  void _ensureSpawned(Size size) {
    if (_size == size) return;
    _size = size;

    // First time sizing -> place hearts across screen
    for (final h in _hearts) {
      h.spawnWithin(_rng, size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          _ensureSpawned(Size(c.maxWidth, c.maxHeight));

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_cTop, _cMid, _cNearWhite, _cWhite],
                stops: [0.0, 0.48, 0.70, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // ===== Falling hearts layer=====
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: _hearts.map((h) {
                          return Positioned(
                            left: h.x,
                            top: h.y,
                            child: Opacity(
                              opacity: h.opacity,
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: h.blur,
                                  sigmaY: h.blur,
                                ),
                                child: Transform.rotate(
                                  angle: h.rotation,
                                  child: Image.asset(
                                    widget.heartAsset,
                                    width: h.size,
                                    height: h.size,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // ===== Foreground content =====
                  Column(
                    children: [
                      const Spacer(flex: 9),
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color.fromARGB(255, 255, 255, 255),
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          widget.logoAsset,
                          width: 86*1.7,
                          height: 86*1.7,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'STEMOSCOPE',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.8,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Your heart, we care',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 34),
                        child: Column(
                          children: [
                            _PillButton(
                              text: 'Get Started',
                              background: const Color(0xFF7D85E6),
                              textColor: const Color(0xFF3E3E3E),
                              onTap: widget.onGetStarted ?? () {},
                              glow: true,
                              glowStrength: 2.2,
                            ),
                            const SizedBox(height: 16),
                            _PillButton(
                              text: 'Sign In',
                              background: const Color(0xFFF1CFEA),
                              textColor: const Color(0xFF6B6B6B),
                              leading: const Icon(
                                Icons.login_rounded,
                                size: 22,
                                color: Color(0xFF6B6B6B),
                              ),
                              onTap: widget.onSignIn ?? () {},
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
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
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeartParticle {

  double x = 0;
  double y = 0;


  double size = 140;
  double opacity = 0.14;
  double blur = 10;
  double rotation = 0;


  double speed = 45; // px/s
  double rotSpeed = 0.10; // rad/s

  _HeartParticle();

  static _HeartParticle random(math.Random rng) {
    final p = _HeartParticle();
    p.size = rng.nextDouble() * 110 + 450;
    p.opacity = rng.nextDouble() * 0.10 + 0.08;
    p.blur = rng.nextDouble() * 5 + 0.4;
    p.speed = rng.nextDouble() * 55 + 25;
    p.rotation = rng.nextDouble() * math.pi * 2;
    p.rotSpeed = (rng.nextDouble() * 0.20 + 0.05) * (rng.nextBool() ? 1 : -1);
    return p;
  }

  void spawnWithin(math.Random rng, Size s) {

    x = rng.nextDouble() * (s.width) - 60;
    y = rng.nextDouble() * s.height - 300;
  }

  void respawn(math.Random rng, Size s) {

    size = rng.nextDouble() * 110 + 450;
    opacity = rng.nextDouble() * 0.10 + 0.08;
    blur = rng.nextDouble() * 5 + 0.4;
    speed = rng.nextDouble() * 55 + 25;
    rotation = rng.nextDouble() * math.pi * 2;
    rotSpeed = (rng.nextDouble() * 0.20 + 0.05) * (rng.nextBool() ? 1 : -1);

    x = rng.nextDouble() * (s.width) - 60;
    y = -rng.nextDouble() * 220 - 300;
  }
}


class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.text,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.leading,
    this.glow = false,
    this.glowStrength = 1.0,
  });

  final String text;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;
  final Widget? leading;


  final bool glow;


  final double glowStrength;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  AnimationController? _glowCtrl;

  @override
  void initState() {
    super.initState();
    _syncGlowController();
  }

  @override
  void didUpdateWidget(covariant _PillButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.glow != widget.glow) _syncGlowController();
  }

  void _syncGlowController() {
    _glowCtrl?.dispose();
    _glowCtrl = null;

    if (widget.glow && widget.glowStrength > 0) {
      _glowCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _glowCtrl?.dispose();
    super.dispose();
  }

  double get _scale {
    if (_pressed) return 0.985;
    if (_hovered) return 1.06;
    return 1.0;
  }

  // helpers
  double _clamp(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

  @override
  Widget build(BuildContext context) {
    final strength = widget.glowStrength;
    final s = strength <= 0 ? 0.0 : strength;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedBuilder(
        animation: _glowCtrl ?? kAlwaysDismissedAnimation,
        builder: (context, child) {

          final t = (_glowCtrl == null)
              ? 0.0
              : (0.5 + 0.5 * math.sin(_glowCtrl!.value * math.pi * 2));


          final glowOpacity = widget.glow
              ? _clamp((0.25 + 0.40 * t) * s, 0.0, 0.95)
              : 0.0;

          final glowBlur = widget.glow ? (18 + 28 * t) * (0.9 + 0.55 * s) : 0.0;
          final glowSpread = widget.glow ? (1 + 9 * t) * (0.7 + 0.65 * s) : 0.0;

          final hoverBoost = _hovered ? 1.15 : 1.0;

          return AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutBack,
            child: Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [

                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),


                  if (widget.glow && s > 0)
    BoxShadow(
    color: widget.background.withOpacity(
      _clamp(glowOpacity * hoverBoost, 0.0, 0.95),
    ),
    blurRadius: glowBlur,
    spreadRadius: glowSpread,
    offset: const Offset(0, 0),
  ),



                  if (widget.glow && s > 0)
                    BoxShadow(
                      color: Colors.white.withOpacity(_clamp(0.18 * t * s, 0.0, 0.35)),
                      blurRadius: 24 * (0.8 + 0.6 * s),
                      spreadRadius: 2.5 * (0.7 + 0.7 * s),
                      offset: const Offset(0, 0),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: widget.onTap,
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTapUp: (_) => setState(() => _pressed = false),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: widget.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

