// lib/scan.dart
import 'package:flutter/material.dart';

enum ScanStep { pickArea, readyToRecord, result }

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    this.onBackToMenu,
    this.onBottomNavTap, // optional: tell menu.dart which tab user tapped
    this.bottomNavIndex = 1, // 0=message, 1=home, 2=settings (default home)
    this.showBottomNav = true,

    this.guyAsset = 'asset/guy.png',
    this.logoAsset = 'asset/heart_icon_logo.png',

    // ✅ background controls
    this.guyWidthFactor = 1.0,   // multiply screen width
    this.guyHeightFactor = 1.3,  // multiply screen height
    this.guyScale = 1,         // extra scale multiplier
    this.guyOffset = const Offset(0, 120), // move background (x,y) in pixels
  });

  final VoidCallback? onBackToMenu;

  /// Optional: let parent (menu.dart) switch tabs when user taps bottom nav.
  /// If null, it just Navigator.pop().
  final ValueChanged<int>? onBottomNavTap;

  final int bottomNavIndex;
  final bool showBottomNav;

  final String guyAsset;
  final String logoAsset;

  final double guyWidthFactor;
  final double guyHeightFactor;
  final double guyScale;
  final Offset guyOffset;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);

  static const _pink = Color(0xFFE85BC2);

  ScanStep _step = ScanStep.pickArea;
  String? _selected;

  static const Map<String, String> _labels = {
    'A': 'Aortic Area',
    'P': 'Pulmonary Area',
    'T': 'Tricuspid Area',
    'M': 'Mitral Area',
  };

  void _backPressed() {
    if (_step == ScanStep.readyToRecord) {
      setState(() {
        _step = ScanStep.pickArea;
        _selected = null;
      });
      return;
    }

    if (_step == ScanStep.result) {
      // back to menu
      if (widget.onBackToMenu != null) {
        widget.onBackToMenu!.call();
      } else {
        Navigator.of(context).maybePop();
      }
      return;
    }

    // pickArea -> normal pop
    Navigator.of(context).maybePop();
  }

  void _onPick(String key) {
    setState(() {
      _selected = key;
      _step = ScanStep.readyToRecord;
    });
  }

  Future<void> _onRecord() async {
    // skip file picker for now
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(99)),
              ),
              const SizedBox(height: 14),
              const Text('Select audio file', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'File picker will be added later.\n(For now, press Continue.)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A9CEC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() => _step = ScanStep.result);
  }

void _handleBottomNavTap(int i) {
  Navigator.of(context).pop(i); // ✅ return selected tab index
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
            clipBehavior: Clip.none,
            children: [
              // ✅ MAIN CONTENT FIRST (so top-left button is NOT blocked)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: _step == ScanStep.result
                    ? _ResultView(
                        key: const ValueKey('result'),
                        onBackToMenu: widget.onBackToMenu ?? () => Navigator.of(context).maybePop(),
                      )
                    : _PickAndRecordView(
    key: ValueKey(_step.toString()),
    step: _step,
    selected: _selected,
    onPick: _onPick,
    onRecord: _onRecord,
    pink: _pink,
    label: _selected == null ? null : (_labels[_selected!] ?? ''),

    guyAsset: widget.guyAsset,
    guyWidthFactor: widget.guyWidthFactor,
    guyHeightFactor: widget.guyHeightFactor,
    guyScale: widget.guyScale,
    guyOffset: widget.guyOffset,

    // ✅ add these
    showBottomNav: widget.showBottomNav,
    bottomNavIndex: widget.bottomNavIndex,
    onBottomNavTap: (i) {
      if (widget.onBottomNavTap != null) {
        widget.onBottomNavTap!(i);
      } else {
        Navigator.of(context).maybePop();
      }
    },
  ),

              ),

              // ✅ TOP BAR ALWAYS ON TOP
              Positioned(
                left: 10,
                top: 6,
                child: IconButton(
                  onPressed: _backPressed,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              Positioned(
                left: 52,
                top: 10,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Image.asset(widget.logoAsset, width: 26, height: 26),
                ),
              ),
              Positioned(
                right: 10,
                top: 6,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),

              // ✅ BOTTOM NAV ON TOP OF BACKGROUND
            ],
          ),
        ),
      ),
    );
  }
}

class _PickAndRecordView extends StatelessWidget {
  const _PickAndRecordView({
    super.key,
    required this.step,
    required this.selected,
    required this.onPick,
    required this.onRecord,
    required this.pink,
    required this.label,

    // background controls
    required this.guyAsset,
    required this.guyWidthFactor,
    required this.guyHeightFactor,
    required this.guyScale,
    required this.guyOffset,

    // bottom nav controls
    required this.showBottomNav,
    required this.bottomNavIndex,
    required this.onBottomNavTap,
  });

  final ScanStep step;
  final String? selected;
  final ValueChanged<String> onPick;
  final Future<void> Function() onRecord;
  final Color pink;
  final String? label;

  final String guyAsset;
  final double guyWidthFactor;
  final double guyHeightFactor;
  final double guyScale;
  final Offset guyOffset;

  final bool showBottomNav;
  final int bottomNavIndex;
  final ValueChanged<int> onBottomNavTap;

  @override
  Widget build(BuildContext context) {
    const points = <String, Offset>{
      'A': Offset(0.45, 0.5),
      'P': Offset(0.55, 0.5),
      'T': Offset(0.50, 0.6),
      'M': Offset(0.60, 0.7),
    };

    // ✅ keep dots stable, and keep buttons fully clickable
    const double baseReserve = 200; // your original reserve
    const double recordLift = 90;   // same "lift" as old -90 translate
    const double bottomReserve = baseReserve + recordLift; // = 290

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // ✅ TRUE BACKGROUND (supports heightFactor > 1)
        Positioned.fill(
          child: Transform.translate(
            offset: guyOffset,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(
                guyScale * guyWidthFactor,
                guyScale * guyHeightFactor,
                1.0,
              ),
              child: Image.asset(
                guyAsset,
                fit: BoxFit.fill,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),

        // ✅ Bottom nav above background, below overlay
        if (showBottomNav)
          Positioned(
            left: 18,
            right: 18,
            bottom: 10,
            child: ScanBottomNav(
              index: bottomNavIndex,
              onTap: (i) => Navigator.of(context).pop(i),

              height: 86,
              scale: 1.18,
              shiftDown: 8,
              extraBottom: 14,
            ),
          ),

        // ✅ UI overlay
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 56),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;

                    return Stack(
                      children: [
                        ...points.entries.map((e) {
                          final k = e.key;
                          final p = e.value;
                          final isSelected = selected == k;

                          return Positioned(
                            left: w * p.dx - 14,
                            top: h * p.dy - 14,
                            child: _DotButton(
                              label: k,
                              selected: isSelected,
                              onTap: () => onPick(k),
                              pink: pink,
                            ),
                          );
                        }),

                        if (step == ScanStep.pickArea)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 30, // your current value
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'เลือกตำแหน่งที่ต้องการ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // ✅ Reserve fixed height so dots never shift
              SizedBox(
                height: bottomReserve,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: step == ScanStep.readyToRecord
                      ? Padding(
                          key: const ValueKey('record_actions'),
                          padding: const EdgeInsets.fromLTRB(26, 0, 26, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _PillAction(text: label ?? 'Selected', filled: false, onTap: () {}),
                              const SizedBox(height: 10),
                              _PillAction(text: 'RECORD', filled: true, onTap: () => onRecord()),
                            ],
                          ),
                        )
                      : const SizedBox(key: ValueKey('empty_actions')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




class _DotButton extends StatelessWidget {
  const _DotButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.pink,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color pink;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? pink : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF333333);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: fg,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  final String text;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFF9A9CEC) : Colors.white;
    final fg = filled ? Colors.white : const Color(0xFF7C32E2);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: fg,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({super.key, required this.onBackToMenu});
  final VoidCallback onBackToMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 56),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultLine(label: 'Aortic Valve : 88%', value: 0.88),
                SizedBox(height: 14),
                _ResultLine(label: 'Tricuspid Valve : 5%', value: 0.05),
                SizedBox(height: 14),
                _ResultLine(label: 'Mitral Valve : 3%', value: 0.03),
                SizedBox(height: 14),
                _ResultLine(label: 'Pulmonary Valve : 0%', value: 0.0),
                SizedBox(height: 14),
                _ResultLine(label: 'Normal : 4%', value: 0.04),
                SizedBox(height: 18),
                Text('Result :', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Mitral Valve - Mild Regurgitation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                SizedBox(height: 10),
                Text(
                  'Base on AI analysis.\nPlease consult a doctor for confirmation.',
                  style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A9CEC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                elevation: 0,
              ),
              onPressed: onBackToMenu,
              child: const Text('Back to Menu', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD9D9D9);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 18,
            color: bg,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFE85BC2), Color(0xFF8A3DFF)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom nav that uses your full-bar images (selected state).
/// Matches your MenuScreen style but self-contained (so scan.dart can use it).
class ScanBottomNav extends StatelessWidget {
  const ScanBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    this.height = 86,
    this.scale = 1.18,
    this.shiftDown = 8,
    this.extraBottom = 14,
  });

  final int index;
  final ValueChanged<int> onTap;

  final double height;
  final double scale;
  final double shiftDown;
  final double extraBottom;

  static const String _msg = 'asset/message_selected.png';
  static const String _home = 'asset/home_selected.png';
  static const String _settings = 'asset/settings_selected.png';

  String get _asset {
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
          Positioned(
            left: 0,
            right: 0,
            bottom: -extraBottom,
            child: Transform.translate(
              offset: Offset(0, shiftDown),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                // ✅ Put BOTH image + tap layer inside the same transform
                child: Stack(
                  children: [
                    Image.asset(
                      _asset,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => onTap(0),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => onTap(1),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => onTap(2),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

