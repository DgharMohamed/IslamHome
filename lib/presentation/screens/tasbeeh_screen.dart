import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';
import 'package:islam_home/data/models/tasbeeh_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/tasbeeh_provider.dart';
import 'package:islam_home/presentation/widgets/aurora_background.dart';
import 'package:islam_home/presentation/widgets/glass_container.dart';

class TasbeehScreen extends ConsumerStatefulWidget {
  const TasbeehScreen({super.key});

  @override
  ConsumerState<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends ConsumerState<TasbeehScreen>
    with TickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _celebrationController;
  late final Animation<double> _celebrationOpacity;
  late final Animation<double> _celebrationScale;

  late final ScrollController _scrollController;
  late final ProviderSubscription<String?> _activeDhikrSubscription;

  final Map<String, GlobalKey> _itemKeys = {};
  bool _showCelebration = false;
  int _sessionCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

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
        Future.delayed(const Duration(milliseconds: 1100), () {
          if (!mounted) return;
          _celebrationController.reverse().then((_) {
            if (mounted) {
              setState(() => _showCelebration = false);
            }
          });
        });
      }
    });

    _activeDhikrSubscription = ref.listenManual<String?>(activeDhikrProvider, (
      previous,
      next,
    ) {
      if (next != null) _scrollToActive(next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToActive(ref.read(activeDhikrProvider));
    });
  }

  @override
  void dispose() {
    _activeDhikrSubscription.close();
    _tapController.dispose();
    _celebrationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive(String? activeId) {
    if (activeId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _itemKeys[activeId];
      final ctx = key?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.45,
      );
    });
  }

  Future<void> _increment(String id, int currentCount, int target) async {
    final isTargetReached = (currentCount + 1) >= target;
    await ref.read(tasbeehListProvider.notifier).increment(id);
    if (!mounted) return;

    setState(() => _sessionCount++);
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

  void _moveToNextDhikr(List<TasbeehModel> list, String? activeId) {
    if (list.isEmpty) return;
    final currentIndex = list.indexWhere((d) => d.id == activeId);
    final safeIndex = currentIndex < 0 ? 0 : currentIndex;
    final nextIndex = (safeIndex + 1) % list.length;
    ref.read(activeDhikrProvider.notifier).set(list[nextIndex].id);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final List<TasbeehModel> dhikrList = ref.watch(tasbeehListProvider);
    final activeId = ref.watch(activeDhikrProvider);

    if (activeId == null && dhikrList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(activeDhikrProvider.notifier).set(dhikrList.first.id);
      });
    }

    final TasbeehModel? activeDhikr = dhikrList.isEmpty
        ? null
        : dhikrList.firstWhere(
            (d) => d.id == (activeId ?? dhikrList.first.id),
            orElse: () => dhikrList.first,
          );

    final tasbeehService = ref.read(tasbeehServiceProvider);
    var totalCount = 0;
    var todayTotal = 0;
    var streak = 0;
    try {
      totalCount = ref.read(tasbeehListProvider.notifier).getTotalCount();
      todayTotal = tasbeehService
          .getDailyStats(DateTime.now())
          .values
          .fold<int>(0, (sum, value) => sum + value);
      streak = tasbeehService.getCurrentStreak();
    } catch (e) {
      debugPrint('TasbeehScreen: failed to read stats: $e');
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom + 130;

    return Scaffold(
      body: AuroraBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, l10n),
                  const SizedBox(height: 10),
                  _buildDhikrSelector(dhikrList, activeDhikr, isArabic),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
                      child: Column(
                        children: [
                          _buildStatsRow(
                            context,
                            l10n: l10n,
                            totalCount: totalCount,
                            todayTotal: todayTotal,
                            streak: streak,
                          ),
                          const SizedBox(height: 26),
                          if (activeDhikr != null)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: Column(
                                key: ValueKey(activeDhikr.id),
                                children: [
                                  _buildDhikrTitle(activeDhikr, isArabic),
                                  const SizedBox(height: 24),
                                  _buildCounterOrb(activeDhikr, l10n),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.tapToCount,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.58,
                                      ),
                                      letterSpacing: 0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 22),
                          _buildActionRow(
                            context,
                            l10n: l10n,
                            activeDhikr: activeDhikr,
                            dhikrList: dhikrList,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showCelebration) _buildCelebrationOverlay(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final sessionLabel = l10n.tasbeehSessionCount(_sessionCount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
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
          Expanded(
            child: Text(
              l10n.electronicTasbeeh,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              sessionLabel,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrSelector(
    List<TasbeehModel> dhikrList,
    TasbeehModel? activeDhikr,
    bool isArabic,
  ) {
    return SizedBox(
      height: 74,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: dhikrList.length,
        itemBuilder: (context, index) {
          final dhikr = dhikrList[index];
          final isActive = activeDhikr != null && dhikr.id == activeDhikr.id;
          final key = _itemKeys.putIfAbsent(dhikr.id, () => GlobalKey());
          final label = isArabic ? dhikr.arabicText : dhikr.text;
          final safeTarget = dhikr.target < 1 ? 1 : dhikr.target;
          final progress = '${dhikr.count}/$safeTarget';

          return Padding(
            key: key,
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => ref.read(activeDhikrProvider.notifier).set(dhikr.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                constraints: const BoxConstraints(minWidth: 132),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primaryColor.withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.14),
                    width: isActive ? 1.8 : 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.24,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: isArabic
                            ? 'Amiri'
                            : GoogleFonts.montserrat().fontFamily,
                        fontSize: 14,
                        color: isActive
                            ? AppTheme.primaryColor
                            : Colors.white70,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: isActive
                            ? AppTheme.primaryColor.withValues(alpha: 0.92)
                            : Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context, {
    required AppLocalizations l10n,
    required int totalCount,
    required int todayTotal,
    required int streak,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.today_rounded,
            label: l10n.today,
            value: '$todayTotal',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_awesome_rounded,
            label: l10n.total,
            value: '$totalCount',
            emphasize: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            label: l10n.streak,
            value: l10n.streakDays(streak),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    bool emphasize = false,
  }) {
    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: emphasize
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.78),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: emphasize ? AppTheme.primaryColor : Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrTitle(TasbeehModel activeDhikr, bool isArabic) {
    return Column(
      children: [
        Text(
          isArabic ? activeDhikr.arabicText : activeDhikr.text,
          style: TextStyle(
            fontFamily: isArabic
                ? 'Amiri'
                : GoogleFonts.montserrat().fontFamily,
            fontSize: isArabic ? 40 : 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
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
        if (!isArabic) ...[
          const SizedBox(height: 6),
          Text(
            activeDhikr.arabicText,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              color: Colors.white70,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildCounterOrb(TasbeehModel activeDhikr, AppLocalizations l10n) {
    final target = activeDhikr.target < 1 ? 1 : activeDhikr.target;
    final count = activeDhikr.count;
    final progress = (count / target).clamp(0.0, 1.0);
    final remaining = (target - count).clamp(0, target);
    final progressPercent = (progress * 100).round();

    final width = MediaQuery.sizeOf(context).width;
    final diameter = ((width - 56) * 0.85).clamp(220.0, 330.0);
    final innerDiameter = diameter - 30;

    return GestureDetector(
      onTap: () => _increment(activeDhikr.id, count, target),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: diameter,
              height: diameter,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
            Container(
              width: innerDiameter,
              height: innerDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.22),
                    blurRadius: 45,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: GlassContainer(
                borderRadius: innerDiameter / 2,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$count',
                        style: GoogleFonts.montserrat(
                          fontSize: innerDiameter * 0.34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '/ $target',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${l10n.next}: $remaining',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppTheme.primaryColor.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progressPercent%',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required AppLocalizations l10n,
    required TasbeehModel? activeDhikr,
    required List<TasbeehModel> dhikrList,
  }) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: [
        _buildActionButton(
          icon: Icons.refresh_rounded,
          label: l10n.reset,
          onTap: () {
            if (activeDhikr != null) _reset(activeDhikr.id);
          },
        ),
        _buildActionButton(
          icon: Icons.flag_rounded,
          label: l10n.setTarget,
          onTap: () {
            if (activeDhikr != null) {
              _showTargetPicker(context, l10n, activeDhikr);
            }
          },
        ),
        _buildActionButton(
          icon: Icons.skip_next_rounded,
          label: l10n.next,
          onTap: () => _moveToNextDhikr(dhikrList, activeDhikr?.id),
        ),
        _buildActionButton(
          icon: Icons.history_rounded,
          label: l10n.history,
          onTap: () => context.push('/tasbeeh/history'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 98,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.86),
                fontWeight: FontWeight.w600,
              ),
            ),
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
              color: Colors.black.withValues(alpha: 0.42),
              alignment: Alignment.center,
              child: ScaleTransition(
                scale: _celebrationScale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.34),
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.62),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.36),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppTheme.primaryColor,
                        size: 52,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.setCompleteTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.setCompleteSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
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
    TasbeehModel activeDhikr,
  ) {
    const targets = [33, 66, 99, 100, 500, 1000];
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.setTarget,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: targets
                  .map(
                    (target) => _buildTargetChip(
                      context: sheetContext,
                      activeDhikrId: activeDhikr.id,
                      target: target,
                      isSelected: activeDhikr.target == target,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetChip({
    required BuildContext context,
    required String activeDhikrId,
    required int target,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () async {
        await ref
            .read(tasbeehListProvider.notifier)
            .updateTarget(activeDhikrId, target);
        if (context.mounted) context.pop();
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Text(
          '$target',
          style: GoogleFonts.montserrat(
            color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
