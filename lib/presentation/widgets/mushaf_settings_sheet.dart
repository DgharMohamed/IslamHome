import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/mushaf_settings_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';

class MushafSettingsSheet extends ConsumerWidget {
  const MushafSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(mushafThemeProvider);
    final mushafSettings = ref.watch(mushafSettingsProvider);
    final isEnglish = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('en');
    final titleText = l10n.mushafSettings;
    final sectionThemeText = l10n.themeLabel;
    final fontSizeLabel = isEnglish ? 'Font Size' : 'حجم الخط';

    return Container(
      decoration: BoxDecoration(
        color: currentTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: currentTheme.textColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: currentTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  titleText,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.textColor,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 28),
            _sectionTitle(sectionThemeText, currentTheme, isEnglish),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemCount: MushafTheme.themes.length,
                itemBuilder: (context, index) {
                  final theme = MushafTheme.themes[index];
                  final isSelected = currentTheme.id == theme.id;

                  return GestureDetector(
                    onTap: () => ref
                        .read(mushafThemeProvider.notifier)
                        .setTheme(theme.id),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsetsDirectional.only(end: 12),
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? currentTheme.secondaryColor
                              : currentTheme.textColor.withValues(alpha: 0.1),
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: currentTheme.secondaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check_rounded,
                                color: currentTheme.secondaryColor,
                                size: 30,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _localizedThemeName(currentTheme.id, isEnglish),
              style: GoogleFonts.cairo(
                color: currentTheme.textColor.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _sectionTitle(fontSizeLabel, currentTheme, isEnglish),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.text_fields_rounded,
                  size: 16,
                  color: currentTheme.textColor.withValues(alpha: 0.6),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: currentTheme.secondaryColor,
                      inactiveTrackColor: currentTheme.secondaryColor.withValues(
                        alpha: 0.15,
                      ),
                      thumbColor: currentTheme.secondaryColor,
                      overlayColor: currentTheme.secondaryColor.withValues(
                        alpha: 0.1,
                      ),
                      valueIndicatorColor: currentTheme.secondaryColor,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    child: Slider(
                      value: mushafSettings.fontSizeScale,
                      min: 1.0,
                      max: 2.0,
                      divisions: 10,
                      label: '${mushafSettings.fontSizeScale.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        ref
                            .read(mushafSettingsProvider.notifier)
                            .setFontSizeScale(value);
                      },
                    ),
                  ),
                ),
                Icon(
                  Icons.text_fields_rounded,
                  size: 28,
                  color: currentTheme.secondaryColor,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, MushafTheme theme, bool isEnglish) {
    return Align(
      alignment: isEnglish ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.secondaryColor,
        ),
      ),
    );
  }

  String _localizedThemeName(String id, bool isEnglish) {
    if (!isEnglish) {
      final theme = MushafTheme.themes.firstWhere(
        (element) => element.id == id,
        orElse: () => MushafTheme.themes.first,
      );
      return theme.name;
    }

    switch (id) {
      case 'cream':
        return 'Cream';
      case 'green':
        return 'Green';
      case 'blue':
        return 'Blue';
      case 'sepia':
        return 'Sepia';
      case 'dark':
        return 'Night';
      case 'black':
        return 'Black';
      default:
        return 'Theme';
    }
  }
}
