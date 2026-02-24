import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/presentation/providers/khatma_provider.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// ─── Dua Data ─────────────────────────────────────────────────────────────────
const List<String> _duaTexts = [
  'اللَّهُمَّ ارْحَمْنِي بالقُرْءَانِ وَاجْعَلْهُ لِي إِمَاماً وَنُوراً وَهُدًى وَرَحْمَةً',
  'اللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نَسِيْتُ وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ وَارْزُقْنِي تِلاَوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ وَاجْعَلْهُ لِي حُجَّةً يَا رَبَّ العَالَمِينَ',
  'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ وَاجْعَلِ المَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ',
  'اللَّهُمَّ اجْعَلْ خَيْرَ عُمْرِي آخِرَهُ وَخَيْرَ عَمَلِي خَوَاتِمَهُ وَخَيْرَ أَيَّامِي يَوْمَ أَلْقَاكَ فِيهِ',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِيشَةً هَنِيَّةً وَمِيتَةً سَوِيَّةً وَمَرَدًّا غَيْرَ مُخْزٍ وَلاَ فَاضِحٍ',
  'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ المَسْأَلَةِ وَخَيْرَ الدُّعَاءِ وَخَيْرَ النَّجَاحِ وَخَيْرَ العِلْمِ وَخَيْرَ العَمَلِ وَخَيْرَ الثَّوَابِ وَخَيْرَ الحَيَاةِ وَخَيْرَ المَمَاتِ وَثَبِّتْنِي وَثَقِّلْ مَوَازِينِي وَحَقِّقْ إِيمَانِي وَارْفَعْ دَرَجَتِي وَتَقَبَّلْ صَلاَتِي وَاغْفِرْ خَطِيئَاتِي وَأَسْأَلُكَ العُلَا مِنَ الجَنَّةِ',
];

// ─── Confetti Particle ────────────────────────────────────────────────────────
class _Particle {
  double x;
  double y;
  double speed;
  double size;
  double angle;
  double spin;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.angle,
    required this.spin,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final currentY = p.y + (size.height * 1.2 * progress * p.speed);
      final currentX = p.x + sin(progress * pi * 4 * p.spin) * 30;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(progress * p.angle * pi * 2);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        ),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

// ─── Main Dialog ──────────────────────────────────────────────────────────────
class DuaKhatmDialog extends ConsumerStatefulWidget {
  final bool isNightMode;
  const DuaKhatmDialog({super.key, this.isNightMode = false});

  @override
  ConsumerState<DuaKhatmDialog> createState() => _DuaKhatmDialogState();
}

class _DuaKhatmDialogState extends ConsumerState<DuaKhatmDialog>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _glowController;
  late PageController _pageController;
  final GlobalKey _repaintKey = GlobalKey();

  int _currentPage = 0;
  final List<_Particle> _particles = [];
  final _random = Random();

  static const _gold = Color(0xFFD4AF37);
  static const _darkBrown = Color(0xFF2C1810);
  static const _cream = Color(0xFFFDFBF7);
  static const _nightBackground = Color(0xFF0D1117);
  static const _nightText = Color(0xFFE8D4B0);

  Color get _bgColor => widget.isNightMode ? _nightBackground : _cream;
  Color get _mainTextColor => widget.isNightMode ? _nightText : _darkBrown;
  Color get _secondaryTextColor =>
      widget.isNightMode ? _gold.withValues(alpha: 0.7) : _gold;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pageController = PageController();

    _generateParticles();
    _confettiController.forward();
  }

  void _generateParticles() {
    const colors = [
      Color(0xFFD4AF37),
      Color(0xFFF5E6A3),
      Color(0xFFB8860B),
      Color(0xFFFFD700),
      Color(0xFFFFF8DC),
      Color(0xFFDAA520),
    ];
    for (int i = 0; i < 60; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble() * 500,
          y: -_random.nextDouble() * 200,
          speed: 0.3 + _random.nextDouble() * 0.7,
          size: 4 + _random.nextDouble() * 8,
          angle: _random.nextDouble() * 2,
          spin: 0.5 + _random.nextDouble(),
          color: colors[_random.nextInt(colors.length)],
        ),
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _shareCurrentDua() async {
    // Capture context-dependent values before any async gap
    final shareText = AppLocalizations.of(context)!.duaKhatm;
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/dua_khatm.png');
      await file.writeAsBytes(pngBytes);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // ── Confetti Layer ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) => CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              ),
            ),
          ),

          // ── Content Layer ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Header with golden glow ──
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      final glowOpacity = 0.15 + _glowController.value * 0.15;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _gold.withValues(alpha: 0.1),
                              Colors.transparent,
                              _gold.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: glowOpacity),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 40,
                              color: _gold,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.duaKhatm,
                              style: GoogleFonts.amiri(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _mainTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.mayAllahAccept,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: _secondaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Dua Carousel ──
                  Flexible(
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: Container(
                        color: _bgColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 260,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _duaTexts.length,
                                onPageChanged: (i) =>
                                    setState(() => _currentPage = i),
                                itemBuilder: (context, index) {
                                  return _DuaCard(
                                    text: _duaTexts[index],
                                    index: index,
                                    isNightMode: widget.isNightMode,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Dot indicators
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _duaTexts.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: _currentPage == i ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == i
                                        ? _gold
                                        : _gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Action Buttons ──
                  Row(
                    children: [
                      // Share button
                      Container(
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: _shareCurrentDua,
                          icon: const Icon(Icons.share_rounded),
                          color: _gold,
                          tooltip: l10n.shareDua,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Complete button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Replay confetti on completion
                            _confettiController.reset();
                            _confettiController.forward();

                            await Future.delayed(
                              const Duration(milliseconds: 800),
                            );
                            final activePlan = ref
                                .read(khatmaProvider)
                                .activePlan;
                            if (activePlan != null) {
                              await ref
                                  .read(khatmaProvider.notifier)
                                  .completeKhatma(activePlan.id);
                            } else {
                              // If they finished without a plan, still call complete to reset progress
                              // Note: completeKhatma currently requires a planId, maybe I should make it nullable
                              // or just return if no plan.
                              await ref
                                  .read(khatmaProvider.notifier)
                                  .completeKhatma('');
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: widget.isNightMode
                                ? _nightBackground
                                : _darkBrown,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.mayAllahAcceptAll,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dua Card Widget ──────────────────────────────────────────────────────────
class _DuaCard extends StatelessWidget {
  final String text;
  final int index;
  final bool isNightMode;

  const _DuaCard({
    required this.text,
    required this.index,
    required this.isNightMode,
  });

  static const _gold = Color(0xFFD4AF37);
  static const _darkBrown = Color(0xFF2C1810);
  static const _nightCard = Color(0xFF161B22);
  static const _nightText = Color(0xFFE8D4B0);

  @override
  Widget build(BuildContext context) {
    final cardBgColor = isNightMode ? _nightCard : Colors.white;
    final textColor = isNightMode ? _nightText : _darkBrown;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative top ornament
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 1,
                color: _gold.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.star_rounded,
                size: 12,
                color: _gold.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 1,
                color: _gold.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 17,
                  height: 2.0,
                  color: textColor.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Page number
          Text(
            '${index + 1} / ${_duaTexts.length}',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: _gold.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
