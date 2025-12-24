// lib/menu.dart
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    this.onTapScan,
    this.onTapHospital,
    this.onTapTelemedicine,
    this.onTapHistory,
    this.onTapPremium,
    this.onTapCalendar,
    this.onTapDailyTask,
    this.onTapNewsItem,
  });

  final VoidCallback? onTapScan;
  final VoidCallback? onTapHospital;
  final VoidCallback? onTapTelemedicine;
  final VoidCallback? onTapHistory;
  final VoidCallback? onTapPremium;
  final VoidCallback? onTapCalendar;
  final VoidCallback? onTapDailyTask;
  final ValueChanged<int>? onTapNewsItem;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _dailyFinished = false;
  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  static const _accentPink = Color(0xFFE85BC2);

  int _tab = 1; // 0=Message, 1=Home, 2=Settings
  int _dailyIndex = 0;
  int _newsIndex = 0;

  final PageController _newsCtrl = PageController(viewportFraction: 1.0);


  // header logo (white)
  static const String _logoAsset = 'asset/heart_icon_logo.png';

  // grid icons
  static const String _scanAsset = 'asset/scan.png';
  static const String _hospitalAsset = 'asset/hospital.png';
  static const String _teleAsset = 'asset/telemedicine.png';
  static const String _historyAsset = 'asset/history.png';
  static const String _premiumAsset = 'asset/premium.png';
  static const String _calendarAsset = 'asset/calendar.png';

  // daily task icons
  static const String _cupBigAsset = 'asset/cup_big.png';
  static const String _cupSmallAsset = 'asset/cup_small.png';

  // news images
  static const List<String> _newsAssets = [
    'asset/news_1.png',
    'asset/news_2.png',
    'asset/news_3.png',
    'asset/news_4.png',
  ];

  @override
  void dispose() {
    _newsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // content (scrollable)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 78), // space for bottom nav
                  child: _buildTab(),
                ),
              ),

              // bottom nav
              Positioned(
                left: 18,
                right: 18,
                bottom: 10,
                child: _BottomNav(
                  index: _tab,
                  onChange: (i) => setState(() => _tab = i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab() {
    if (_tab == 0) return _PlaceholderTab(title: 'MESSAGE');
    if (_tab == 2) return _PlaceholderTab(title: 'SETTINGS');
    return _HomeTab(
      dailyFinished: _dailyFinished,
      onToggleDailyFinished: () => setState(() => _dailyFinished = !_dailyFinished),
      logoAsset: _logoAsset,
      scanAsset: _scanAsset,
      hospitalAsset: _hospitalAsset,
      teleAsset: _teleAsset,
      historyAsset: _historyAsset,
      premiumAsset: _premiumAsset,
      calendarAsset: _calendarAsset,
      cupBigAsset: _cupBigAsset,
      cupSmallAsset: _cupSmallAsset,
      newsAssets: _newsAssets,
      dailyIndex: _dailyIndex,
      onDailyIndexChange: (v) => setState(() => _dailyIndex = v),
      newsIndex: _newsIndex,
      onNewsIndexChange: (v) => setState(() => _newsIndex = v),
      newsCtrl: _newsCtrl,
      accentPink: _accentPink,
      onTapScan: widget.onTapScan,
      onTapHospital: widget.onTapHospital,
      onTapTelemedicine: widget.onTapTelemedicine,
      onTapHistory: widget.onTapHistory,
      onTapPremium: widget.onTapPremium,
      onTapCalendar: widget.onTapCalendar,
      onTapDailyTask: widget.onTapDailyTask,
      onTapNewsItem: widget.onTapNewsItem,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.dailyFinished,
    required this.onToggleDailyFinished,
    required this.logoAsset,
    required this.scanAsset,
    required this.hospitalAsset,
    required this.teleAsset,
    required this.historyAsset,
    required this.premiumAsset,
    required this.calendarAsset,
    required this.cupBigAsset,
    required this.cupSmallAsset,
    required this.newsAssets,
    required this.dailyIndex,
    required this.onDailyIndexChange,
    required this.newsIndex,
    required this.onNewsIndexChange,
    required this.newsCtrl,
    required this.accentPink,
    this.onTapScan,
    this.onTapHospital,
    this.onTapTelemedicine,
    this.onTapHistory,
    this.onTapPremium,
    this.onTapCalendar,
    this.onTapDailyTask,
    this.onTapNewsItem,
  });
  final bool dailyFinished;
  final VoidCallback onToggleDailyFinished;

  final String logoAsset;
  final String scanAsset;
  final String hospitalAsset;
  final String teleAsset;
  final String historyAsset;
  final String premiumAsset;
  final String calendarAsset;

  final String cupBigAsset;
  final String cupSmallAsset;

  final List<String> newsAssets;

  final int dailyIndex;
  final ValueChanged<int> onDailyIndexChange;

  final int newsIndex;
  final ValueChanged<int> onNewsIndexChange;
  final PageController newsCtrl;

  final Color accentPink;

  final VoidCallback? onTapScan;
  final VoidCallback? onTapHospital;
  final VoidCallback? onTapTelemedicine;
  final VoidCallback? onTapHistory;
  final VoidCallback? onTapPremium;
  final VoidCallback? onTapCalendar;
  final VoidCallback? onTapDailyTask;
  final ValueChanged<int>? onTapNewsItem;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // header
          Row(
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Image.asset(
                  logoAsset,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'STEMOSCOPE',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // grid card
          _Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MenuTile(
                          asset: scanAsset,
                          label: 'SCAN',
                          onTap: onTapScan ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: hospitalAsset,
                          label: 'HOSPITAL',
                          onTap: onTapHospital ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: teleAsset,
                          label: 'TELEMEDICINE',
                          onTap: onTapTelemedicine ?? () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MenuTile(
                          asset: historyAsset,
                          label: 'HISTORY',
                          onTap: onTapHistory ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: premiumAsset,
                          label: 'PREMIUM',
                          onTap: onTapPremium ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: calendarAsset,
                          label: 'CALENDAR',
                          onTap: onTapCalendar ?? () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          _SectionPill(title: 'DAILY TASK', color: const Color(0xFFE9CFEA)),

          const SizedBox(height: 10),

          _Card(
            child: GestureDetector(
              onTap: onTapDailyTask ?? () {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Image.asset(cupBigAsset, width: 54, height: 54, fit: BoxFit.contain),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'ดื่มน้ำ 8 แก้ว',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _FinishButton(
                          finished: dailyFinished,
                          onToggle: onToggleDailyFinished,
                        ),

                        ],
                      ),
                    ),
                    Image.asset(cupSmallAsset, width: 36, height: 36, fit: BoxFit.contain),
                    const SizedBox(width: 10),
                    _CircleArrow(
                      onTap: onTapDailyTask ?? () {},
                      bg: const Color(0xFFBFC2FF),
                      iconColor: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          _Dots(count: 4, index: dailyIndex, activeColor: accentPink, inactiveColor: const Color(0xFFD7D7D7)),

          const SizedBox(height: 14),

          _SectionPill(title: 'NEWS', color: const Color(0xFFBFC2FF)),
          const SizedBox(height: 10),

          _Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: newsCtrl,
                          itemCount: newsAssets.length,
                          onPageChanged: onNewsIndexChange,
                          itemBuilder: (context, i) {
                            return GestureDetector(
                              onTap: () => onTapNewsItem?.call(i),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  newsAssets[i],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),

                        // left arrow
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CircleArrow(
                              onTap: () {
                                final prev = (newsIndex - 1).clamp(0, newsAssets.length - 1);
                                newsCtrl.animateToPage(
                                  prev,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              bg: const Color(0xFFDADADA).withOpacity(0.60),
                              iconColor: Colors.black,
                              left: true,
                            ),
                          ),
                        ),

                        // right arrow
                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CircleArrow(
                              onTap: () {
                                final next = (newsIndex + 1).clamp(0, newsAssets.length - 1);
                                newsCtrl.animateToPage(
                                  next,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              bg: const Color(0xFFDADADA).withOpacity(0.60),
                              iconColor: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'กดเพื่ออ่านเพิ่มเติม',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          _Dots(count: newsAssets.length, index: newsIndex, activeColor: accentPink, inactiveColor: const Color(0xFFD7D7D7)),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _MenuTile extends StatefulWidget {
  const _MenuTile({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: Container(
            height: 94,
            decoration: BoxDecoration(
              color: const Color(0xFFF6EAF4),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(widget.asset, width: 34, height: 34, fit: BoxFit.contain),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5A2A86),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _CircleArrow extends StatelessWidget {
  const _CircleArrow({
    required this.onTap,
    required this.bg,
    required this.iconColor,
    this.left = false,
  });

  final VoidCallback onTap;
  final Color bg;
  final Color iconColor;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(
          left ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  const _FinishButton({
    required this.finished,
    required this.onToggle,
  });

  final bool finished;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final Color bg = finished ? const Color(0xFF9A9CEC) : const Color(0xFFD7D7D7);
    final Color fg = finished ? Colors.white : const Color(0xFF4B4B4B);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        height: 34,
        width: 160,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            if (finished)
              BoxShadow(
                color: bg.withOpacity(0.55),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          transitionBuilder: (child, anim) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            );
          },
          child: Text(
            finished ? 'FINISHED' : 'FINISH',
            key: ValueKey<bool>(finished),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: fg,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}


class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onChange});

  final int index;
  final ValueChanged<int> onChange;

  static const _accentPink = Color(0xFFE85BC2);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              label: 'MESSAGE',
              icon: Icons.chat_bubble_outline_rounded,
              active: index == 0,
              onTap: () => onChange(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              label: 'HOME',
              icon: Icons.home_rounded,
              active: index == 1,
              onTap: () => onChange(1),
              activeColor: _accentPink,
            ),
          ),
          Expanded(
            child: _NavItem(
              label: 'SETTINGS',
              icon: Icons.settings_rounded,
              active: index == 2,
              onTap: () => onChange(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.activeColor = _activeDefault,
  });

  static const Color _activeDefault = Color(0xFF111111);

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : const Color(0xFF111111);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
      ),
    );
  }
}
