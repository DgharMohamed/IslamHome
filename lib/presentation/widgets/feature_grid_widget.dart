import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/responsive_utils.dart';

class FeatureGridWidget extends StatelessWidget {
  const FeatureGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = ResponsiveUtils.isWide(context);

    // --- SECTION 1: Quran & Islamic Knowledge ---
    final quranSection = [
      _FeatureItem(
        title: l10n.quranMushaf,
        subtitle: l10n.quranSubtitle,
        icon: FontAwesomeIcons.bookQuran,
        color: const Color(0xFFC2185B),
        route: '/quran',
      ),
      _FeatureItem(
        title: l10n.audioTafsir,
        icon: FontAwesomeIcons.headphones,
        color: const Color(0xFF4527A0),
        route: '/tafsir',
      ),
      _FeatureItem(
        title: l10n.videoLibraryTitle,
        icon: FontAwesomeIcons.circlePlay,
        color: const Color(0xFFBF360C),
        route: '/video',
      ),
      _FeatureItem(
        title: l10n.azkarDuas,
        icon: FontAwesomeIcons.handsPraying,
        color: const Color(0xFF1565C0),
        route: '/azkar',
      ),
      _FeatureItem(
        title: l10n.propheticHadith,
        icon: FontAwesomeIcons.bookOpenReader,
        color: const Color(0xFF6A1B9A),
        route: '/hadith',
      ),
    ];

    // --- SECTION 2: Worship & Prayer Tools ---
    final worshipSection = [
      _FeatureItem(
        title: l10n.prayerTimes,
        icon: FontAwesomeIcons.mosque,
        color: const Color(0xFFF57F17),
        route: '/prayer-times',
      ),
      _FeatureItem(
        title: l10n.qibla,
        icon: FontAwesomeIcons.kaaba,
        color: const Color(0xFF00838F),
        route: '/qibla',
      ),
      _FeatureItem(
        title: l10n.tasbeeh,
        icon: FontAwesomeIcons.fingerprint,
        color: const Color(0xFF5D4037),
        route: '/tasbeeh',
      ),
    ];

    // --- SECTION 3: Media & Entertainment ---
    final mediaSection = [
      _FeatureItem(
        title: l10n.radioLive,
        icon: FontAwesomeIcons.radio,
        color: const Color(0xFF2E7D32),
        route: '/radio',
      ),
      _FeatureItem(
        title: l10n.liveTv,
        icon: FontAwesomeIcons.tv,
        color: const Color(0xFFE65100),
        route: '/live-tv',
      ),
    ];

    // --- SECTION 4: My Library ---
    final librarySection = [
      _FeatureItem(
        title: l10n.favorites,
        icon: FontAwesomeIcons.solidHeart,
        color: const Color(0xFFD81B60),
        route: '/favorites',
      ),
      _FeatureItem(
        title: l10n.downloads,
        icon: FontAwesomeIcons.download,
        color: const Color(0xFF00695C),
        route: '/downloads',
      ),
      _FeatureItem(
        title: l10n.settings,
        icon: FontAwesomeIcons.gear,
        color: const Color(0xFF455A64),
        route: '/settings',
      ),
    ];

    if (isWide) {
      // On wide screens keep a flat grid
      final all = [
        ...quranSection,
        ...worshipSection,
        ...mediaSection,
        ...librarySection,
      ];
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.getCrossAxisCount(
            context,
            tablet: 3,
            desktop: 5,
          ),
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: all.length,
        itemBuilder: (context, index) => _FeatureCard(item: all[index]),
      );
    }

    // Mobile: Sectioned horizontal rows
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionRow(
          label: '📖 ${l10n.homeSectionQuranAndSeerah}',
          items: quranSection,
          onBuild: (item) => _FeatureCard(item: item),
        ),
        const SizedBox(height: 24),
        _SectionRow(
          label: '🕌 ${l10n.homeSectionWorshipAndPrayer}',
          items: worshipSection,
          onBuild: (item) => _FeatureCard(item: item),
        ),
        const SizedBox(height: 24),
        _SectionRow(
          label: '📺 ${l10n.homeSectionMediaAndBroadcast}',
          items: mediaSection,
          onBuild: (item) => _FeatureCard(item: item),
        ),
        const SizedBox(height: 24),
        _SectionRow(
          label: '📂 ${l10n.homeSectionMyLibrary}',
          items: librarySection,
          onBuild: (item) => _FeatureCard(item: item),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isWide = ResponsiveUtils.isWide(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: InkWell(
          onTap: item.route != null ? () => context.push(item.route!) : null,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isWide
                ? null
                : 120, // Only fix width on mobile horizontal scroll
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? item.color.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? item.color.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.2),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: Offset(0, _isHovered ? 6 : 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(
                      alpha: _isHovered ? 0.25 : 0.15,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(
                          alpha: _isHovered ? 0.5 : 0.3,
                        ),
                        blurRadius: _isHovered ? 15 : 10,
                        spreadRadius: _isHovered ? 0 : -2,
                      ),
                    ],
                  ),
                  child: FaIcon(
                    item.icon,
                    color: _isHovered ? Colors.white : item.color,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    item.title,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isHovered
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.9),
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

/// A horizontal section with a header label
class _SectionRow extends StatelessWidget {
  final String label;
  final List<_FeatureItem> items;
  final Widget Function(_FeatureItem) onBuild;

  const _SectionRow({
    required this.label,
    required this.items,
    required this.onBuild,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.12),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(overscroll: false),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => onBuild(items[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem {
  final String title;
  final String? subtitle;
  final FaIconData icon;
  final Color color;
  final String? route;

  _FeatureItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.route,
  });
}
