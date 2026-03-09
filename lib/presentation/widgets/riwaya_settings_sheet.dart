import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/core/theme/app_theme.dart';
import 'package:islam_home/data/models/mushaf_riwaya.dart';
import 'package:islam_home/l10n/generated/app_localizations.dart';
import 'package:islam_home/presentation/providers/mushaf_riwaya_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';

class RiwayaSettingsSheet extends ConsumerWidget {
  const RiwayaSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(mushafThemeProvider);
    final selectedRiwaya = ref.watch(selectedRiwayaProvider);
    final isEnglish = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('en');

    final titleText = l10n.riwayaSettings;
    final subtitleText = l10n.chooseQuranRecitationStyle;
    final downloadsLabel = l10n.downloadMoreRiwayat;

    return Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Container(
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
              Text(
                subtitleText,
                style: GoogleFonts.cairo(
                  color: currentTheme.textColor.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ...MushafRiwaya.all
                  .where((r) => r.isOffline)
                  .map(
                    (riwaya) => _RiwayaTile(
                      riwaya: riwaya,
                      isSelected: selectedRiwaya.key == riwaya.key,
                      theme: currentTheme,
                      isEnglish: isEnglish,
                      l10n: l10n,
                    ),
                  ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: currentTheme.textColor.withValues(alpha: 0.08),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        downloadsLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: currentTheme.textColor.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: currentTheme.textColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
              ...MushafRiwaya.all
                  .where((r) => !r.isOffline)
                  .map(
                    (riwaya) => _RiwayaTile(
                      riwaya: riwaya,
                      isSelected: selectedRiwaya.key == riwaya.key,
                      theme: currentTheme,
                      isEnglish: isEnglish,
                      l10n: l10n,
                    ),
                  ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiwayaTile extends ConsumerWidget {
  final MushafRiwaya riwaya;
  final bool isSelected;
  final MushafTheme theme;
  final bool isEnglish;
  final AppLocalizations l10n;

  const _RiwayaTile({
    required this.riwaya,
    required this.isSelected,
    required this.theme,
    required this.isEnglish,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadManager = ref.watch(riwayaDownloadManagerProvider);
    final state = downloadManager[riwaya.key];
    final isDownloaded = riwaya.isOffline || (state?.isDownloaded ?? false);
    final isDownloading = state?.isDownloading ?? false;
    final progress = state?.progress ?? 0.0;

    return GestureDetector(
      onTap: () async {
        if (!isDownloaded && !riwaya.isOffline) {
          await ref
              .read(riwayaDownloadManagerProvider.notifier)
              .downloadRiwaya(riwaya);
        }
        if (isDownloaded || riwaya.isOffline) {
          ref.read(selectedRiwayaProvider.notifier).selectRiwaya(riwaya);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.secondaryColor.withValues(alpha: 0.12)
              : theme.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.secondaryColor
                : theme.textColor.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.secondaryColor.withValues(alpha: 0.15)
                        : theme.textColor.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : riwaya.isOffline
                          ? Icons.menu_book_rounded
                          : isDownloaded
                          ? Icons.check_circle_outline_rounded
                          : Icons.download_rounded,
                      color: isSelected
                          ? theme.secondaryColor
                          : isDownloaded || riwaya.isOffline
                          ? AppTheme.matteGold
                          : theme.textColor.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riwaya.name,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.secondaryColor
                              : theme.textColor,
                        ),
                      ),
                      Text(
                        isEnglish
                            ? '${riwaya.rawiName} via ${riwaya.qiraaName}'
                            : '${riwaya.rawiName} عن ${riwaya.qiraaName}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: theme.textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (riwaya.isOffline)
                  _badge(l10n.available, Colors.green)
                else if (isDownloaded)
                  _badge(l10n.downloaded, Colors.blue)
                else if (!isDownloading)
                  _badge(l10n.download, AppTheme.primaryColor),
              ],
            ),
            if (isDownloading) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.textColor.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.secondaryColor,
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: isEnglish
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: theme.textColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
