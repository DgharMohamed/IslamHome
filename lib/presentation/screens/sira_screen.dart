import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/data/models/sira_model.dart';
import 'package:islam_home/core/utils/scaffold_utils.dart';

class SiraScreen extends ConsumerWidget {
  const SiraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siraAsync = ref.watch(siraProvider);
    final l10n = AppLocalizations.of(context)!;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: context.canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  )
                : IconButton(
                    icon: const Icon(Icons.menu_rounded, size: 28),
                    onPressed: () => GlobalScaffoldService.openDrawer(),
                  ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                l10n.sira,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.4),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -20,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.03),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_edu_rounded,
                              size: 48,
                              color: AppTheme.primaryColor,
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
          siraAsync.when(
            data: (stages) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final stage = stages[index];
                  return _buildSiraCard(
                    context,
                    stage,
                    isArabic,
                    index == stages.length - 1,
                  );
                }, childCount: stages.length),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text(l10n.error(err.toString()))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiraCard(
    BuildContext context,
    SiraStage stage,
    bool isArabic,
    bool isLast,
  ) {
    final languageCode = isArabic ? 'ar' : 'en';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getIcon(stage.icon),
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: InkWell(
                onTap: () => context.push('/sira/detail', extra: stage),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              stage.getTitle(languageCode),
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (stage.yearLabel.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    stage.yearLabel,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.white24,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stage.getDescription(languageCode),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'baby_changing_station':
        return Icons.child_care_rounded;
      case 'work_history':
        return Icons.business_center_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'campaign':
        return Icons.campaign_rounded;
      case 'nights_stay':
        return Icons.nights_stay_rounded;
      case 'flight_takeoff':
        return Icons.flight_takeoff_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'terrain':
        return Icons.terrain_rounded;
      case 'landscape':
        return Icons.landscape_rounded;
      case 'handshake':
        return Icons.handshake_rounded;
      case 'castle':
        return Icons.fort_rounded;
      case 'forest':
        return Icons.forest_rounded;
      case 'mosque':
        return Icons.mosque_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.history_edu_rounded;
    }
  }
}
