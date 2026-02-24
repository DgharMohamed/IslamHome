import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/presentation/widgets/aurora_background.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/presentation/providers/tasbeeh_provider.dart';

class TasbeehScreen extends ConsumerStatefulWidget {
  const TasbeehScreen({super.key});

  @override
  ConsumerState<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends ConsumerState<TasbeehScreen>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;

  late AnimationController _celebrationController;
  late Animation<double> _celebrationOpacity;
  late Animation<double> _celebrationScale;

  bool _showCelebration = false;
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to active dhikr on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final activeId = ref.read(activeDhikrProvider);
        _scrollToActive(activeId);
      }
    });

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _celebrationScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _celebrationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            _celebrationController.reverse().then((_) {
              if (mounted) setState(() => _showCelebration = false);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tapController.dispose();
    _celebrationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive(String? activeId) {
    if (activeId == null) return;

    // Use a short delay to ensure the list is rendered and keys are assigned
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _itemKeys[activeId];
      if (key?.currentContext != null && mounted) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.5, // Center the item
        );
      }
    });
  }

  Future<void> _increment(String id, int currentCount, int target) async {
    final isTargetReached = (currentCount + 1) >= target;
    await ref.read(tasbeehListProvider.notifier).increment(id);
    _tapController.forward().then((_) => _tapController.reverse());

    if (isTargetReached) {
      HapticFeedback.heavyImpact();
      setState(() => _showCelebration = true);
      _celebrationController.forward(from: 0);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _reset(String id) {
    ref.read(tasbeehListProvider.notifier).reset(id);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dhikrList = ref.watch(tasbeehListProvider);
    final activeId = ref.watch(activeDhikrProvider);

    // Listen to changes in the activeId to center the selected item
    ref.listen<String?>(activeDhikrProvider, (previous, next) {
      if (next != null) {
        _scrollToActive(next);
      }
    });

    final activeDhikr = dhikrList.isEmpty
        ? null
        : dhikrList.firstWhere(
            (d) => d.id == activeId,
            orElse: () => dhikrList.first,
          );

    return Scaffold(
      body: AuroraBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(context, l10n),
                  const SizedBox(height: 30),

                  // Dhikr Selection List
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dhikrList.length,
                      itemBuilder: (context, index) {
                        final dhikr = dhikrList[index];
                        final isActive = dhikr.id == activeDhikr?.id;

                        // Maintain a GlobalKey for each item to allow scrolling to it
                        final key = _itemKeys.putIfAbsent(
                          dhikr.id,
                          () => GlobalKey(),
                        );

                        return Padding(
                          key: key,
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => ref
                                .read(activeDhikrProvider.notifier)
                                .set(dhikr.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.primaryColor.withValues(
                                        alpha: 0.15,
                                      )
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? AppTheme.primaryColor
                                      : Colors.white.withValues(alpha: 0.1),
                                  width: isActive ? 2 : 1,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'ar'
                                      ? dhikr.arabicText
                                      : dhikr.text,
                                  style: TextStyle(
                                    fontFamily:
                                        Localizations.localeOf(
                                              context,
                                            ).languageCode ==
                                            'ar'
                                        ? 'Amiri'
                                        : GoogleFonts.inter().fontFamily,
                                    fontSize: 16,
                                    color: isActive
                                        ? AppTheme.primaryColor
                                        : Colors.white60,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                  _buildTotalStats(
                    l10n,
                    ref.read(tasbeehListProvider.notifier).getTotalCount(),
                  ),
                  const SizedBox(height: 40),

                  // Active Dhikr Arabic Text
                  if (activeDhikr != null) ...[
                    Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? activeDhikr.arabicText
                          : activeDhikr.text,
                      style: TextStyle(
                        fontFamily:
                            Localizations.localeOf(context).languageCode == 'ar'
                            ? 'Amiri'
                            : GoogleFonts.inter().fontFamily,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (Localizations.localeOf(context).languageCode != 'ar')
                      Text(
                        activeDhikr.arabicText,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24,
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],

                  const SizedBox(height: 40),

                  // Main Counter with Progress Ring
                  if (activeDhikr != null)
                    GestureDetector(
                      onTap: () => _increment(
                        activeDhikr.id,
                        activeDhikr.count,
                        activeDhikr.target,
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 280,
                              height: 280,
                              child: CircularProgressIndicator(
                                value: activeDhikr.count / activeDhikr.target,
                                strokeWidth: 10,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: GlassContainer(
                                borderRadius: 125,
                                padding: EdgeInsets.zero,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${activeDhikr.count}',
                                        style: const TextStyle(
                                          fontSize: 90,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '/ ${activeDhikr.target}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          color: Colors.white54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 50),
                  Text(
                    l10n.tapToCount,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white38,
                      fontFamily: 'Cairo',
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavActionButton(
                          Icons.refresh_rounded,
                          l10n.reset,
                          () {
                            if (activeDhikr != null) _reset(activeDhikr.id);
                          },
                        ),
                        _buildNavActionButton(
                          Icons.tune_rounded,
                          l10n.setTarget,
                          () {
                            if (activeDhikr != null) {
                              _showTargetPicker(context, l10n, activeDhikr);
                            }
                          },
                        ),
                        _buildNavActionButton(
                          Icons.history_rounded,
                          l10n.history,
                          () => context.push('/tasbeeh/history'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Set-complete celebration overlay
            if (_showCelebration) _buildCelebrationOverlay(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay(AppLocalizations l10n) {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, _) {
        return IgnorePointer(
          child: Opacity(
            opacity: _celebrationOpacity.value,
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
              alignment: Alignment.center,
              child: ScaleTransition(
                scale: _celebrationScale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppTheme.primaryColor,
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.setCompleteTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.setCompleteSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTargetPicker(
    BuildContext context,
    AppLocalizations l10n,
    dynamic activeDhikr,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 30,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.setTarget,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: [33, 66, 99, 100, 1000].map((t) {
                final isSelected = activeDhikr.target == t;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(tasbeehListProvider.notifier)
                        .updateTarget(activeDhikr.id, t);
                    context.pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.white10,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      '$t',
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => context.canPop()
                ? context.pop()
                : GlobalScaffoldService.openDrawer(),
          ),
          Text(
            l10n.electronicTasbeeh,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTotalStats(AppLocalizations l10n, int total) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Column(
        children: [
          Text(
            l10n.totalTasbeehs,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white54,
              fontFamily: 'Cairo',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$total',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 26),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
