// lib/menu.dart
import 'package:flutter/material.dart';
import 'messages.dart';
import 'oops.dart';
import 'scan.dart';
import 'messages.dart';
import 'settings.dart';

class DailyBannerSpec {
  const DailyBannerSpec({
    required this.asset,
    required this.finishPos, // (0..1, 0..1) where (0,0)=top-left
    this.finishOffset = Offset.zero, // pixel nudge
  });

  final String asset;
  final Offset finishPos;
  final Offset finishOffset;
}

Alignment _alignFromFraction(Offset f) {
  // Convert (0..1,0..1) -> Alignment(-1..1,-1..1)
  return Alignment(f.dx * 2 - 1, f.dy * 2 - 1);
}

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
  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  static const _accentPink = Color(0xFFE85BC2);

  int _tab = 1; // 0=Message, 1=Home, 2=Settings
  int _dailyIndex = 0;
  int _newsIndex = 0;

  final PageController _newsCtrl = PageController(viewportFraction: 1.0);
  final PageController _dailyCtrl = PageController(viewportFraction: 1.0);

  static const String _logoAsset = 'asset/login_logo.png';

  static const String _scanAsset = 'asset/scan.png';
  static const String _hospitalAsset = 'asset/hospital.png';
  static const String _teleAsset = 'asset/telemedicine.png';
  static const String _historyAsset = 'asset/history.png';
  static const String _premiumAsset = 'asset/premium.png';
  static const String _calendarAsset = 'asset/calendar.png';

  static const List<DailyBannerSpec> _dailyBanners = [
    DailyBannerSpec(asset: 'asset/banner_1.png', finishPos: Offset(0.50, 0.82)),
    DailyBannerSpec(asset: 'asset/banner_2.png', finishPos: Offset(0.50, 0.82)),
    DailyBannerSpec(asset: 'asset/banner_3.png', finishPos: Offset(0.50, 0.82)),
    DailyBannerSpec(asset: 'asset/banner_4.png', finishPos: Offset(0.50, 0.82)),
  ];

  late final List<bool> _dailyFinished = List<bool>.filled(_dailyBanners.length, false);

  static const List<String> _newsAssets = [
    'asset/news_1.png',
    'asset/news_2.png',
    'asset/news_3.png',
    'asset/news_4.png',
  ];

  @override
  void dispose() {
    _dailyCtrl.dispose();
    _newsCtrl.dispose();
    super.dispose();
  }

  void _openOops() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OopsScreen()),
    );
  }

  Future<void> _openScan() async {
    debugPrint('MENU: openScan() current _tab=$_tab');

    final selectedTab = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => ScanScreen(
          bottomNavIndex: _tab,
          showBottomNav: true,

          // ✅ THIS is the key fix: update menu tab immediately when Scan nav pressed
          onBottomNavTap: (i) {
            debugPrint('MENU: onBottomNavTap from Scan -> $i');
            if (!mounted) return;
            setState(() => _tab = i);
          },
        ),
      ),
    );

    debugPrint('MENU: received pop result from Scan -> $selectedTab');

    if (!mounted) return;
    if (selectedTab != null) {
      setState(() => _tab = selectedTab);
      debugPrint('MENU: setState from pop result _tab=$_tab');
    }
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
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 78),
                  child: _buildTab(),
                ),
              ),
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
    debugPrint('MENU: _buildTab using _tab=$_tab');

    if (_tab == 0) return const MessagesTab();
    if (_tab == 2) return const SettingsTab();


    return _HomeTab(
      logoAsset: _logoAsset,
      scanAsset: _scanAsset,
      hospitalAsset: _hospitalAsset,
      teleAsset: _teleAsset,
      historyAsset: _historyAsset,
      premiumAsset: _premiumAsset,
      calendarAsset: _calendarAsset,

      // DAILY
      dailyBanners: _dailyBanners,
      dailyFinished: _dailyFinished,
      onToggleDailyFinishedAt: (i) => setState(() => _dailyFinished[i] = !_dailyFinished[i]),
      dailyIndex: _dailyIndex,
      onDailyIndexChange: (v) => setState(() => _dailyIndex = v),
      dailyCtrl: _dailyCtrl,

      // NEWS
      newsAssets: _newsAssets,
      newsIndex: _newsIndex,
      onNewsIndexChange: (v) => setState(() => _newsIndex = v),
      newsCtrl: _newsCtrl,

      accentPink: _accentPink,

      // ✅ Buttons
      onTapScan: _openScan,
      onTapHospital: _openOops,
      onTapTelemedicine: _openOops,
      onTapHistory: _openOops,
      onTapPremium: _openOops,
      onTapCalendar: _openOops,

      onTapDailyTask: widget.onTapDailyTask,
      onTapNewsItem: widget.onTapNewsItem,
    );
  }
}



class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.logoAsset,
    required this.scanAsset,
    required this.hospitalAsset,
    required this.teleAsset,
    required this.historyAsset,
    required this.premiumAsset,
    required this.calendarAsset,

    // DAILY
    required this.dailyBanners,
    required this.dailyFinished,
    required this.onToggleDailyFinishedAt,
    required this.dailyIndex,
    required this.onDailyIndexChange,
    required this.dailyCtrl,

    // NEWS
    required this.newsAssets,
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

  final String logoAsset;
  final String scanAsset;
  final String hospitalAsset;
  final String teleAsset;
  final String historyAsset;
  final String premiumAsset;
  final String calendarAsset;

  // DAILY
  final List<DailyBannerSpec> dailyBanners;
  final List<bool> dailyFinished;
  final ValueChanged<int> onToggleDailyFinishedAt;
  final int dailyIndex;
  final ValueChanged<int> onDailyIndexChange;
  final PageController dailyCtrl;

  // NEWS
  final List<String> newsAssets;
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
          // Header
          Row(
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Image.asset(
                  logoAsset,
                  width: 70,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'STEMOSCOPE',
                  style: TextStyle(
                    fontSize: 30,
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

          // Grid card
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
                          onTap: onTapScan ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: hospitalAsset,
                          onTap: onTapHospital ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: teleAsset,
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
                          onTap: onTapHistory ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: premiumAsset,
                          onTap: onTapPremium ?? () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuTile(
                          asset: calendarAsset,
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

          // DAILY TASK banner slider
          _Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: dailyCtrl,
                          itemCount: dailyBanners.length,
                          onPageChanged: onDailyIndexChange,
                          itemBuilder: (context, i) {
                            final spec = dailyBanners[i];

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  GestureDetector(
                                    onTap: onTapDailyTask ?? () {},
                                    child: Image.asset(spec.asset, fit: BoxFit.cover),
                                  ),
                                  Align(
                                    alignment: _alignFromFraction(spec.finishPos),
                                    child: Transform.translate(
                                      offset: spec.finishOffset,
                                      child: _FinishButton(
                                        finished: dailyFinished[i],
                                        onToggle: () => onToggleDailyFinishedAt(i),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CircleArrow(
                              onTap: () {
                                final prev = (dailyIndex - 1).clamp(0, dailyBanners.length - 1);
                                dailyCtrl.animateToPage(
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

                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CircleArrow(
                              onTap: () {
                                final next = (dailyIndex + 1).clamp(0, dailyBanners.length - 1);
                                dailyCtrl.animateToPage(
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

                  const SizedBox(height: 6),
                  _Dots(
                    count: dailyBanners.length,
                    index: dailyIndex,
                    activeColor: accentPink,
                    inactiveColor: const Color(0xFFD7D7D7),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          _SectionPill(title: 'NEWS', color: const Color(0xFFBFC2FF)),
          const SizedBox(height: 10),

          // NEWS slider
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
          _Dots(
            count: newsAssets.length,
            index: newsIndex,
            activeColor: accentPink,
            inactiveColor: const Color(0xFFD7D7D7),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}


class _MenuTile extends StatefulWidget {
  const _MenuTile({
    required this.asset,
    required this.onTap,
    this.hoverScale = 1.06,
    this.pressScale = 0.97,
  });

  final String asset;
  final VoidCallback onTap;
  final double hoverScale;
  final double pressScale;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? widget.pressScale : (_hover ? widget.hoverScale : 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent, // still only hits where child is painted
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: Image.asset(
            widget.asset,
            fit: BoxFit.contain,
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
  const _BottomNav({
    required this.index,
    required this.onChange,
    this.height = 78,        // tap area height
    this.scale = 1.2,       // enlarge PNG (try 1.05..1.35)
    this.shiftDown = 46,      // move PNG down (try 0..18)
    this.extraBottom = 12,   // allow PNG to extend down (try 0..30)
  });

  final int index;
  final ValueChanged<int> onChange;

  final double height;
  final double scale;
  final double shiftDown;
  final double extraBottom;

  static const String _msg = 'asset/message_selected.png';
  static const String _home = 'asset/home_selected.png';
  static const String _settings = 'asset/settings_selected.png';

  String get _barAsset {
    switch (index) {
      case 0:
        return _msg;
      case 2:
        return _settings;
      case 1:
      default:
        return _home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // BAR IMAGE (can extend below using extraBottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: -extraBottom, // allow overflow downward
            child: Transform.translate(
              offset: Offset(0, shiftDown),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  _barAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // TAP ZONES (3 equal sections)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onChange(0),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onChange(1),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onChange(2),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                ),
              ],
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
    required this.inactiveIcon,
    required this.selectedAsset,
    required this.active,
    required this.hovered,
    required this.onTap,
    required this.onHover,
    required this.activeColor,
  });

  final String label;
  final IconData inactiveIcon;
  final String selectedAsset;

  final bool active;
  final bool hovered;

  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final bool showSelected = active || hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutBack,
              scale: hovered ? 1.08 : 1.0,
              child: showSelected
                  ? Image.asset(
                      selectedAsset,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    )
                  : Icon(inactiveIcon, color: Colors.black, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: showSelected ? activeColor : const Color(0xFF111111),
              ),
            ),
          ],
        ),
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
