import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/core/utils/quran_utils.dart';

class DrawerWidget extends ConsumerWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // Premium Branding Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.15),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.appTitle,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.sidebarAppDescription,
                  style: GoogleFonts.tajawal(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader(l10n.home),
                _buildDrawerItem(
                  Icons.home_rounded,
                  l10n.home,
                  '/',
                  context,
                  ref,
                ),

                const SizedBox(height: 20),
                _buildSectionHeader(l10n.homeSectionQuranAndSeerah),
                _buildDrawerItem(
                  Icons.menu_book_rounded,
                  l10n.quranMushaf,
                  '/quran',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.people_alt_rounded,
                  l10n.reciters,
                  '/all-reciters',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.headset_rounded,
                  l10n.audioTafsir,
                  '/tafsir',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.video_library_rounded,
                  l10n.videoLibraryTitle,
                  '/video',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.import_contacts_rounded,
                  l10n.azkarDuas,
                  '/azkar',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.history_edu_rounded,
                  l10n.propheticHadith,
                  '/hadith',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.auto_awesome_rounded,
                  l10n.sira,
                  '/sira',
                  context,
                  ref,
                ),
                ref
                    .watch(lastReadPositionProvider)
                    .when(
                      data: (pos) => _buildDrawerItem(
                        Icons.bookmark_rounded,
                        pos != null
                            ? l10n.lastReadAyah(
                                QuranUtils.getSurahName(
                                  pos.surahNumber,
                                  isEnglish: l10n.localeName == 'en',
                                ),
                                pos.ayahNumber.toString(),
                              )
                            : l10n.noBookmarkSaved,
                        'bookmark',
                        context,
                        ref,
                      ),
                      loading: () => _buildDrawerItem(
                        Icons.bookmark_rounded,
                        l10n.noBookmarkSaved,
                        'bookmark',
                        context,
                        ref,
                      ),
                      error: (_, _) => _buildDrawerItem(
                        Icons.bookmark_rounded,
                        l10n.noBookmarkSaved,
                        'bookmark',
                        context,
                        ref,
                      ),
                    ),

                const SizedBox(height: 20),
                _buildSectionHeader(l10n.homeSectionWorshipAndPrayer),
                _buildDrawerItem(
                  Icons.access_time_filled_rounded,
                  l10n.prayerTimes,
                  '/prayer-times',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.compass_calibration_rounded,
                  l10n.qibla,
                  '/qibla',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.touch_app_rounded,
                  l10n.tasbeeh,
                  '/tasbeeh',
                  context,
                  ref,
                ),

                const SizedBox(height: 20),
                _buildSectionHeader(l10n.homeSectionMediaAndBroadcast),
                _buildDrawerItem(
                  Icons.radio_rounded,
                  l10n.radioLive,
                  '/radio',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.live_tv_rounded,
                  l10n.liveTv,
                  '/live-tv',
                  context,
                  ref,
                ),

                const SizedBox(height: 20),
                _buildSectionHeader(l10n.homeSectionMyLibrary),
                _buildDrawerItem(
                  Icons.favorite_rounded,
                  l10n.favorites,
                  '/favorites',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.download_for_offline_rounded,
                  l10n.downloads,
                  '/downloads',
                  context,
                  ref,
                ),
                _buildDrawerItem(
                  Icons.settings_rounded,
                  l10n.settings,
                  '/settings',
                  context,
                  ref,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cairo(
          color: Colors.white24,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    String route,
    BuildContext context,
    WidgetRef ref,
  ) {
    final bool isSelected = GoRouterState.of(context).uri.toString() == route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2))
            : null,
      ),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.white54,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        onTap: () {
          context.pop(); // Close drawer
          if (route == 'bookmark') {
            final lastReadPos = ref.read(lastReadPositionProvider).value;
            if (lastReadPos != null) {
              context.push(
                '/quran?surah=${lastReadPos.surahNumber}&ayah=${lastReadPos.ayahNumber}',
              );
            } else {
              context.push('/quran');
            }
          } else {
            context.push(route);
          }
        },
      ),
    );
  }
}
