import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/presentation/widgets/mushaf_verse_marker.dart';
import 'package:islam_home/data/models/quran_content_model.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/core/utils/quran_utils.dart';

class MushafTextPage extends ConsumerWidget {
  final int pageNumber;
  final int? highlightedAyah;

  const MushafTextPage({
    super.key,
    required this.pageNumber,
    this.highlightedAyah,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranPageAsync = ref.watch(quranPageProvider(pageNumber));
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3E0), // Mushaf paper color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: quranPageAsync.when(
        data: (data) {
          if (data == null || data.ayahs == null || data.ayahs!.isEmpty) {
            return Center(child: Text(l10n.errorLoadingPage));
          }

          return SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: _buildMushafFlow(context, data.ayahs!),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        error: (err, stack) => Center(child: Text(l10n.errorLoadingPage)),
      ),
    );
  }

  Widget _buildMushafFlow(BuildContext context, List<Ayah> ayahs) {
    List<InlineSpan> spans = [];
    int? currentSurah;

    String toArabicDigits(int number) {
      const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      String res = number.toString();
      for (int i = 0; i < english.length; i++) {
        res = res.replaceAll(english[i], arabic[i]);
      }
      return res;
    }

    for (var ayah in ayahs) {
      // Add Surah header if it starts on this page
      if (currentSurah != ayah.surah?.number) {
        currentSurah = ayah.surah?.number;
        spans.add(
          WidgetSpan(child: _buildSurahHeader(context, ayah.surah?.name ?? '')),
        );

        // Add Bismillah if it's the start of a surah (and not Fatiha/Tawbah)
        if (ayah.numberInSurah == 1 &&
            ayah.surah?.number != 1 &&
            ayah.surah?.number != 9) {
          spans.add(
            WidgetSpan(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                    style: GoogleFonts.amiriQuran(
                      fontSize: 22,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }

      int? startingJuz;
      for (var entry in QuranUtils.juzMapping.entries) {
        if (entry.value['surah'] == ayah.surah?.number &&
            entry.value['ayah'] == ayah.numberInSurah) {
          startingJuz = entry.key;
          break;
        }
      }

      int? startingHizb;
      for (var entry in QuranUtils.hizbMapping.entries) {
        if (entry.value['surah'] == ayah.surah?.number &&
            entry.value['ayah'] == ayah.numberInSurah) {
          startingHizb = entry.key;
          break;
        }
      }

      if ((startingJuz != null && startingJuz > 1) ||
          (startingHizb != null && startingHizb > 1)) {
        String markerText = '';
        if (startingJuz != null && startingJuz > 1)
          markerText += 'نهاية الجزء ${toArabicDigits(startingJuz - 1)}';
        if (startingJuz != null &&
            startingJuz > 1 &&
            startingHizb != null &&
            startingHizb > 1)
          markerText += ' • ';
        if (startingHizb != null && startingHizb > 1)
          markerText += 'نهاية الحزب ${toArabicDigits(startingHizb - 1)}';

        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '۞ ',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                  ),
                  Text(
                    markerText,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37).withOpacity(0.9),
                    ),
                  ),
                  const Text(
                    ' ۞',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
        spans.add(const TextSpan(text: ' '));
      }

      final isHighlighted = highlightedAyah == ayah.numberInSurah;

      spans.add(
        TextSpan(
          text: ayah.text ?? '',
          style: GoogleFonts.amiriQuran(
            fontSize: 24,
            height: 1.8,
            color: isHighlighted
                ? Colors.red.shade900
                : const Color(0xFF2C1810),
            backgroundColor: isHighlighted
                ? Colors.yellow.withValues(alpha: 0.3)
                : null,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: MushafVerseMarker(
            verseNumber: ayah.numberInSurah ?? 0,
            color: const Color(0xFFD4AF37),
            size: 28,
          ),
        ),
      );

      // Add space between ayahs
      spans.add(const TextSpan(text: ' '));

      // Add special end marker for the very end of the Quran
      if (ayah.surah?.number == 114 && ayah.numberInSurah == 6) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '۞ ',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                  ),
                  Text(
                    'نهاية الجزء ٦٠ • نهاية الحزب ٦٠',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD4AF37).withOpacity(0.9),
                    ),
                  ),
                  const Text(
                    ' ۞',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Text.rich(TextSpan(children: spans), textAlign: TextAlign.justify);
  }

  Widget _buildSurahHeader(BuildContext context, String surahName) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/surah_header_bg.png'), // Or a border
          fit: BoxFit.contain,
        ),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'سورة $surahName',
          style: GoogleFonts.amiriQuran(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ),
      ),
    );
  }
}
