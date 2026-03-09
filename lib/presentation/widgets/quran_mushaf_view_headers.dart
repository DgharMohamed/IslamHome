import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';

class SurahHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> element;
  final MushafTheme theme;
  final VoidCallback? onTapSurahName;

  const SurahHeaderWidget({
    super.key,
    required this.element,
    required this.theme,
    this.onTapSurahName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.secondaryColor.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "آياتها\n${quran.getVerseCount(element["surah"])}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontFamily: 'Amiri',
                  ),
                ),
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTapSurahName,
                    child: Text(
                      quran.getSurahNameArabic(element["surah"]),
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: theme.textColor,
                      ),
                    ),
                  ),
                ),
                Text(
                  "ترتيبها\n${element["surah"]}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontFamily: 'Amiri',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BismillahWidget extends StatelessWidget {
  final MushafTheme theme;
  const BismillahWidget({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          quran.basmala,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            color: theme.textColor,
          ),
        ),
      ),
    );
  }
}
