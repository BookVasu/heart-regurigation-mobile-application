// lib/messages.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({
    super.key,
    this.onMenu,
    this.onSend,
    this.logoAsset = 'asset/login_logo.png',
  });

  final VoidCallback? onMenu;
  final VoidCallback? onSend;
  final String logoAsset;

  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            // faint background docs
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.08,
                  child: Stack(
                    children: const [
                      _BgDocIcon(left: -18, top: 6, size: 190, rotationDeg: -18),
                      _BgDocIcon(right: -30, top: 28, size: 220, rotationDeg: 22),
                    ],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 10),

                // header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        child: Image.asset(logoAsset, width: 36*2.6, height: 36*2.6),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'MENTOR CHATBOT',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onMenu,
                        child: const Icon(Icons.menu_rounded, size: 28, color: Colors.black),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 0),

                // chat panel
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // messages area
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 74),
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              children: const [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: _Bubble(
                                    text: 'HELLO!',
                                    mine: true,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _Bubble(
                                    text: 'Hi~ how’s your day been?',
                                    mine: false,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // input bar overlay
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: _InputBar(onSend: onSend),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});
  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF5A5E98);
    final pad = mine
        ? const EdgeInsets.fromLTRB(16, 10, 16, 10)
        : const EdgeInsets.fromLTRB(16, 12, 16, 12);

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: pad,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  const _InputBar({this.onSend});
  final VoidCallback? onSend;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFF5A5E98),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),

          // plus
          _CircleIcon(
            bg: const Color(0xFF7C81B8),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
            onTap: () {},
          ),

          const SizedBox(width: 0),

          // placeholder field (looks like your mock)
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'How can I help you today?',
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // mic
          const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),

          // send
          _CircleIcon(
            bg: const Color(0xFFE85BC2),
            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
            onTap: () {
              widget.onSend?.call();
              _ctrl.clear();
            },
          ),

          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.bg,
    required this.child,
    required this.onTap,
  });

  final Color bg;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: child,
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
