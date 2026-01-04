// lib/scan.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;


import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

// your existing imports:
import 'package:flutter/material.dart';

// make sure these exist in your project:
import 'loading.dart'; // contains HeartSplashScreen (your loading.dart)
import 'oops.dart';    // contains OopsScreen
import 'dart:typed_data';

enum ScanStep { pickArea, readyToRecord, result }

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    this.onBackToMenu,
    this.onBottomNavTap, // optional: tell menu.dart which tab user tapped
    this.bottomNavIndex = 1, // 0=message, 1=home, 2=settings (default home)
    this.showBottomNav = true,

    this.guyAsset = 'asset/guy.png',
    this.logoAsset = 'asset/login_logo.png',

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
  // --- API ---
  static const String _baseUrl = 'https://debsirin49513-space-test.hf.space';
  static const String _analyzeUrl = '$_baseUrl/analyze';

  // --- theme ---
  static const _cTop = Color(0xFFC3C0FA);
  static const _cMid = Color(0xFFF4E0F0);
  static const _cNearWhite = Color(0xFFFFFEFE);
  static const _cWhite = Color(0xFFFFFFFF);
  static const _pink = Color(0xFFE85BC2);

  // --- flow ---
  ScanStep _step = ScanStep.pickArea;
  String? _selected;

  // --- result from API ---
  double? _prob; // 0..1 (higher = more likely abnormal)
  String? _pickedFileName;

  static const Map<String, String> _labels = {
    'A': 'Aortic Area',
    'P': 'Pulmonary Area',
    'T': 'Tricuspid Area',
    'M': 'Mitral Area',
  };

  void _onPick(String k) {
    setState(() {
      _selected = k;
      _step = ScanStep.readyToRecord;
    });
  }

  void _backPressed() {
    // from ready -> back to pick screen (doesn't leave Scan)
    if (_step == ScanStep.readyToRecord) {
      setState(() {
        _step = ScanStep.pickArea;
        _selected = null;
      });
      return;
    }

    // result or pick screen -> back to menu (leave Scan)
    if (widget.onBackToMenu != null) {
      widget.onBackToMenu!.call();
    } else {
      Navigator.of(context).maybePop();
    }
  }


Future<Map<String, dynamic>?> _callAnalyzeApiSafe(PlatformFile pf) async {
  try {
    final req = http.MultipartRequest('POST', Uri.parse(_analyzeUrl));

    if (pf.bytes != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'file',
          Uint8List.fromList(pf.bytes!),
          filename: pf.name,
        ),
      );
    } else if (pf.readStream != null) {
      req.files.add(
        http.MultipartFile(
          'file',
          pf.readStream!,
          pf.size,
          filename: pf.name,
        ),
      );
    } else if (pf.path != null) {
      req.files.add(await http.MultipartFile.fromPath('file', pf.path!, filename: pf.name));
    } else {
      return null;
    }

    final res = await req.send().timeout(const Duration(seconds: 60));
    final body = await res.stream.bytesToString();

    debugPrint('SCAN API status=${res.statusCode}');
    if (res.statusCode != 200) {
      debugPrint('SCAN API body=$body');
      return null;
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map) return null;
    return decoded.cast<String, dynamic>();
  } catch (e) {
    debugPrint('SCAN API error: $e');
    return null;
  }
}




Future<void> _onRecord() async {
  try {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['wav', 'mp3'],
      withData: true,        // ✅ web + sometimes mobile
      withReadStream: true,  // ✅ REQUIRED for Android content:// cases
    );

    if (picked == null || picked.files.isEmpty) return;
    final pf = picked.files.single;
    _pickedFileName = pf.name;

    if (!mounted) return;

    // ✅ open loading
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => const HeartSplashScreen(),
        transitionsBuilder: (_, anim, __, child) {
          final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: a, child: child);
        },
      ),
    );

    // ✅ call API
    final jsonMap = await _callAnalyzeApiSafe(pf);

    if (!mounted) return;

    // ✅ close loading safely (only if we can pop)
    Navigator.of(context).maybePop();

    if (jsonMap == null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, __, ___) => const OopsScreen(),
          transitionsBuilder: (_, anim, __, child) {
            final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: a, child: child);
          },
        ),
      );
      return;
    }

    final result = (jsonMap['result'] as Map?)?.cast<String, dynamic>();
    final prob = (result?['probability'] as num?)?.toDouble();

    if (prob == null) {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (_, __, ___) => const OopsScreen(),
          transitionsBuilder: (_, anim, __, child) {
            final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: a, child: child);
          },
        ),
      );
      return;
    }

    setState(() {
      _prob = prob;
      _step = ScanStep.result;
    });
  } catch (e, st) {
    debugPrint('SCAN: record flow failed -> $e');
    debugPrint('$st');

    if (!mounted) return;

    // close loading if it’s open
    Navigator.of(context).maybePop();

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) => const OopsScreen(),
        transitionsBuilder: (_, anim, __, child) {
          final a = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(opacity: a, child: child);
        },
      ),
    );
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
            clipBehavior: Clip.none,
            children: [
              // ✅ MAIN CONTENT FIRST
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: _step == ScanStep.result
                    ? _ResultView(
                        key: const ValueKey('result'),
                        probability: _prob ?? 0.0,
                        fileName: _pickedFileName,
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

                        // background controls
                        guyAsset: widget.guyAsset,
                        guyWidthFactor: widget.guyWidthFactor,
                        guyHeightFactor: widget.guyHeightFactor,
                        guyScale: widget.guyScale,
                        guyOffset: widget.guyOffset,

                        // bottom nav passthrough (Scan -> Menu)
                        showBottomNav: widget.showBottomNav,
                        bottomNavIndex: widget.bottomNavIndex,
                        onBottomNavTap: (i) {
                          widget.onBottomNavTap?.call(i); // update Menu immediately (if provided)
                          Navigator.of(context).pop(i);   // also return int result
                        },
                      ),
              ),

              // ✅ TOP BAR
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
  onTap: (i) {
    debugPrint('SCAN bottomNav tapped -> $i');
    Navigator.of(context).pop(i);
  },
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
  const _ResultView({
    super.key,
    required this.probability,
    required this.onBackToMenu,
    this.fileName,
  });

  final double probability; // 0..1 (higher => more likely abnormal)
  final VoidCallback onBackToMenu;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final p = probability.clamp(0.0, 1.0);
    final percent = (p * 100).toStringAsFixed(1);
    final abnormal = p >= 0.5;

    final title = 'ABNORMAL LIKELIHOOD';
    final message = abnormal
        ? 'Based on the analysis, this recording has a higher likelihood of abnormal patterns. Please consult a doctor for professional diagnosis.'
        : 'Based on the analysis, this recording has a low likelihood of abnormal patterns. Keep regular checkups and maintain a healthy lifestyle.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 80, 22, 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RESULT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
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
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: abnormal ? const Color(0xFFE85BC2) : const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (fileName != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      fileName!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 220,
              height: 44,
              child: ElevatedButton(
                onPressed: onBackToMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE85BC2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                ),
                child: const Text(
                  'BACK TO MENU',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

