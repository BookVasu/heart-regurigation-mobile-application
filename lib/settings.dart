// lib/settings.dart
import 'package:flutter/material.dart';
import 'oops.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({
    super.key,
    this.profileAsset = 'asset/profile.png',
    this.displayName = 'Woratawat Karumdecha',
    this.isPremium = true,
  });

  final String profileAsset;
  final String displayName;
  final bool isPremium;

  static const _accentPink = Color(0xFFE85BC2);

  void _openOops(BuildContext context) {
    Navigator.of(context).push(_fadeSlide(const OopsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: MenuScreen already provides gradient background + bottom nav overlay.
    // So this widget only draws the content.
    return Stack(
      children: [
        // faint background decorations (optional)
        Positioned(
          right: -24,
          top: 10,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.18,
              child: Transform.rotate(
                angle: -0.25,
                child: Image.asset(
                  'asset/report_bg.png',
                  width: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -30,
          top: 130,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'asset/heart_bg.png',
                width: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        Positioned(
          left: -20,
          bottom: 120,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.10,
              child: Image.asset(
                'asset/stethoscope_bg.png',
                width: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),

        // main content
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 110), // leave room for bottom nav
          child: Column(
            children: [
              // top bar (logo left, hamburger right)
              Row(
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    child: Image.asset(
                      'asset/heart_icon_logo.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // profile
              _ProfileHeader(
                profileAsset: profileAsset,
                displayName: displayName,
                isPremium: isPremium,
              ),

              const SizedBox(height: 14),

              // buttons
              _SettingsButton(
                icon: Icons.edit_rounded,
                label: 'EDIT PROFILE',
                onTap: () => _openOops(context),
              ),
              const SizedBox(height: 10),
              _SettingsButton(
                icon: Icons.lock_rounded,
                label: 'ACCOUNT PRIVACY',
                onTap: () => _openOops(context),
              ),
              const SizedBox(height: 10),
              _SettingsButton(
                icon: Icons.notifications_rounded,
                label: 'UPDATES',
                onTap: () => _openOops(context),
              ),
              const SizedBox(height: 10),
              _SettingsButton(
                icon: Icons.person_rounded,
                label: 'CONNECTED PLATFORM',
                onTap: () => _openOops(context),
              ),
              const SizedBox(height: 10),
              _SettingsButton(
                icon: Icons.info_rounded,
                label: 'ABOUT US',
                onTap: () => _openOops(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profileAsset,
    required this.displayName,
    required this.isPremium,
  });

  final String profileAsset;
  final String displayName;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // avatar circle
        Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: Image.asset(
              profileAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Icon(Icons.person, size: 44),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black.withOpacity(0.45),
          ),
        ),

        const SizedBox(height: 4),

        if (isPremium)
          Text(
            '👑Premium👑',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black.withOpacity(0.40),
            ),
          ),
      ],
    );
  }
}

class _SettingsButton extends StatefulWidget {
  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.01 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),

                // left icon pill
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6EAF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    widget.icon,
                    size: 18,
                    color: const Color(0xFFE85BC2),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

PageRouteBuilder _fadeSlide(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.02),
        end: Offset.zero,
      ).animate(a);

      return FadeTransition(
        opacity: a,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
