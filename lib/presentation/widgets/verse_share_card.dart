import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class VerseShareCard extends StatelessWidget {
  final int surah;
  final int ayah;
  final MushafTheme theme;
  final AppLocalizations l10n;
  final bool isEnglish;

  const VerseShareCard({
    super.key,
    required this.surah,
    required this.ayah,
    required this.theme,
    required this.l10n,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final surahName = isEnglish 
        ? QuranUtils.getSurahName(surah, isEnglish: true) 
        : quran.getSurahNameArabic(surah);
    final verseText = quran.getVerse(surah, ayah, verseEndSymbol: true);
    
    final bgColor = theme.backgroundColor;
    final textColor = theme.textColor;
    final borderColor = theme.secondaryColor;
    final footerColor = theme.secondaryColor.withValues(alpha: 0.15);

    return Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Container(
        color: bgColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            
            // Surah Name Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 1.5),
                  bottom: BorderSide(color: borderColor, width: 1.5),
                ),
              ),
              child: Text(
                isEnglish ? 'Surah $surahName' : 'سُورَةُ $surahName',
                style: TextStyle(
                  fontFamily: 'Amiri', // Or UthmanicHafs
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Ayah Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                verseText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: 28,
                  height: 1.8,
                  color: textColor,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Footer with curved top
            ClipPath(
              clipper: _WaveClipper(),
              child: Container(
                width: double.infinity,
                color: footerColor,
                padding: const EdgeInsets.only(top: 32, bottom: 24, left: 24, right: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Right side: App Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.contain),
                    ),
                    
                    // Center side: Text
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              l10n.sharedFromApp,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Simple decorative ornament
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 30, height: 1.5, color: borderColor),
                                const SizedBox(width: 8),
                                Icon(Icons.circle, size: 4, color: borderColor),
                                const SizedBox(width: 8),
                                Container(width: 30, height: 1.5, color: borderColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Left side: Empty placeholder for balance
                    const SizedBox(width: 56),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 20);
    path.quadraticBezierTo(size.width / 4, 0, size.width / 2, 0);
    path.quadraticBezierTo(size.width * 3 / 4, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
