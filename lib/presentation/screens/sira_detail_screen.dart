import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/data/models/sira_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class SiraDetailScreen extends StatelessWidget {
  final SiraStage stage;

  const SiraDetailScreen({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final languageCode = isArabic ? 'ar' : 'en';
    final events = stage.getEvents(languageCode);
    final lesson = stage.getLesson(languageCode);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 60,
                vertical: 12,
              ),
              title: Text(
                stage.getTitle(languageCode),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 15,
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
                      AppTheme.primaryColor.withValues(alpha: 0.25),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          _getIcon(stage.icon),
                          size: 32,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (stage.yearLabel.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            stage.yearLabel,
                            style: GoogleFonts.cairo(
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // — Description chip —
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    stage.getDescription(languageCode),
                    textAlign: TextAlign.center,
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: GoogleFonts.cairo(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // — Main content —
                _sectionCard(
                  icon: Icons.menu_book_rounded,
                  title: l10n.storySectionTitle,
                  child: Text(
                    stage.getContent(languageCode),
                    textAlign: isArabic ? TextAlign.justify : TextAlign.left,
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: isArabic
                        ? GoogleFonts.amiri(
                            fontSize: 20,
                            height: 2.0,
                            color: Colors.white.withValues(alpha: 0.92),
                          )
                        : GoogleFonts.montserrat(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // — Events timeline —
                if (events.isNotEmpty)
                  _sectionCard(
                    icon: Icons.timeline_rounded,
                    title: l10n.keyEventsTitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: events.asMap().entries.map((entry) {
                        final i = entry.key;
                        final text = entry.value;
                        final isLast = i == events.length - 1;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 1.5,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: isLast ? 0 : 16,
                                  ),
                                  child: Text(
                                    text,
                                    textDirection: isArabic
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 14,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 16),

                // — Lesson —
                if (lesson != null && lesson.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.12),
                          AppTheme.primaryColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          children: [
                            const Icon(
                              Icons.lightbulb_rounded,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.keyLessonTitle,
                              style: GoogleFonts.cairo(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lesson,
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            height: 1.7,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
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
