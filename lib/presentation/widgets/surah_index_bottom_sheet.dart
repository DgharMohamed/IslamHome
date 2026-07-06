import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';
import 'package:islam_home/core/utils/quran_utils.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';

class SurahIndexBottomSheet extends ConsumerStatefulWidget {
  final Function(int)? onSurahSelected;
  const SurahIndexBottomSheet({super.key, this.onSurahSelected});

  @override
  ConsumerState<SurahIndexBottomSheet> createState() =>
      _SurahIndexBottomSheetState();
}

class _SurahIndexBottomSheetState extends ConsumerState<SurahIndexBottomSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(mushafThemeProvider);
    const surahCount = quran.totalSurahCount;
    final normalizedQuery = QuranUtils.normalizeForSearch(_searchQuery);
    final isEnglish = AppLocalizations.of(context)!.localeName == 'en';

    final filteredSurahs = List.generate(surahCount, (i) => i + 1).where((id) {
      final nameAr = quran.getSurahNameArabic(id);
      final nameEn = QuranUtils.getSurahName(id, isEnglish: true);
      return QuranUtils.matchesSearch(nameAr, normalizedQuery) ||
          QuranUtils.matchesSearch(nameEn, normalizedQuery) ||
          QuranUtils.matchesSearch(id.toString(), normalizedQuery);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.surahIndex,
                  style: GoogleFonts.amiri(
                    color: theme.secondaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.surahsCount(surahCount),
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: theme.textColor),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchSurah,
                hintStyle: TextStyle(
                  color: theme.textColor.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(Icons.search, color: theme.secondaryColor),
                filled: true,
                fillColor: theme.textColor.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: filteredSurahs.length,
              separatorBuilder: (context, index) => Divider(
                color: theme.textColor.withValues(alpha: 0.05),
                indent: 70,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final id = filteredSurahs[index];
                return Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.secondaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$id',
                        style: TextStyle(
                          color: theme.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      isEnglish
                          ? QuranUtils.getSurahName(id, isEnglish: true)
                          : quran.getSurahNameArabic(id),
                      style: GoogleFonts.amiri(
                        color: theme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      isEnglish
                          ? '${quran.getSurahNameArabic(id)} • ${AppLocalizations.of(context)!.ayahsCount(quran.getVerseCount(id))}'
                          : AppLocalizations.of(
                              context,
                            )!.ayahsCount(quran.getVerseCount(id)),
                      style: TextStyle(
                        color: theme.textColor.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: theme.textColor.withValues(alpha: 0.3),
                    ),
                    onTap: () {
                      widget.onSurahSelected?.call(id);
                      Navigator.pop(context, id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
