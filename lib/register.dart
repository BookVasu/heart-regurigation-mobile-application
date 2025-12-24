// lib/register.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    this.onBack,
    this.onCreate,
    this.heartAsset = 'asset/heart_icon_logo.png',
  });

  final VoidCallback? onBack;
  final VoidCallback? onCreate;
  final String heartAsset;

  // same gradient family as your other screens
  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

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
            stops: [0.0, 0.50, 0.72, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // faint background "report" vibe
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.07,
                    child: Stack(
                      children: const [
                        _BgDocIcon(left: -10, top: 40, size: 170, rotationDeg: -18),
                        _BgDocIcon(right: -20, top: 10, size: 190, rotationDeg: 18),
                        _BgDocIcon(right: 10, top: 110, size: 130, rotationDeg: 8),
                      ],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 70),

                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: onBack ?? () => Navigator.of(context).maybePop(),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Opacity(
                                  opacity: 0.35,
                                  child: Image.asset(
                                    heartAsset,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                const _Field(hint: 'Name'),
                                const SizedBox(height: 14),
                                const _Field(hint: 'Surname'),
                                const SizedBox(height: 14),
                                const _Field(hint: 'Enter email or phone number'),
                                const SizedBox(height: 14),
                                const _Field(hint: 'Password', obscure: true),

                                const SizedBox(height: 18),

                                // CREATE button
                                GestureDetector(
                                  onTap: onCreate ?? () {},
                                  child: Container(
                                    height: 52,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9A9CEC),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.14),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'CREATE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ),

                  // footer
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
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.hint, this.obscure = false});

  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6C6C6C), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF4A4A4A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF4A4A4A), width: 1.2),
        ),
      ),
    );
  }
}

class _BgDocIcon extends StatelessWidget {
  const _BgDocIcon({
    this.left,
    this.right,
    this.top,
    this.bottom,
    required this.size,
    required this.rotationDeg,
  });

  final double? left, right, top, bottom;
  final double size;
  final double rotationDeg;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Transform.rotate(
        angle: rotationDeg * math.pi / 180,
        child: Icon(Icons.description_rounded, size: size, color: Colors.black),
      ),
    );
  }
}
