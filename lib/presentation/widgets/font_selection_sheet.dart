import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islam_home/data/models/quran_font_model.dart';
import 'package:islam_home/data/services/quran_font_service.dart';
import 'package:islam_home/presentation/providers/mushaf_settings_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_theme_provider.dart';

class FontSelectionSheet extends ConsumerStatefulWidget {
  const FontSelectionSheet({super.key});

  @override
  ConsumerState<FontSelectionSheet> createState() => _FontSelectionSheetState();
}

class _FontSelectionSheetState extends ConsumerState<FontSelectionSheet> {
  final Map<String, bool> _downloadedCache = {};
  final Map<String, double> _downloadProgress = {};
  final Set<String> _loadedFonts = {};

  @override
  void initState() {
    super.initState();
    _checkDownloadedFonts();
  }

  Future<void> _checkDownloadedFonts() async {
    final fontService = ref.read(quranFontServiceProvider);
    for (final font in QuranFont.all) {
      if (font.isBundled) {
        _downloadedCache[font.id] = true;
      } else {
        final downloaded = await fontService.isFontDownloaded(font);
        if (mounted) {
          setState(() {
            _downloadedCache[font.id] = downloaded;
          });
          // Pre-load already downloaded fonts into the engine
          if (downloaded) {
            await fontService.loadFont(font);
            _loadedFonts.add(font.id);
          }
        }
      }
    }
  }

  Future<void> _downloadFont(QuranFont font) async {
    final fontService = ref.read(quranFontServiceProvider);

    setState(() {
      _downloadProgress[font.id] = 0.0;
    });

    final path = await fontService.downloadFont(
      font,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[font.id] = progress;
          });
        }
      },
    );

    if (path != null && mounted) {
      final loaded = await fontService.loadFont(font);
      if (loaded && mounted) {
        setState(() {
          _downloadedCache[font.id] = true;
          _downloadProgress.remove(font.id);
          _loadedFonts.add(font.id);
        });
      }
    } else if (mounted) {
      setState(() {
        _downloadProgress.remove(font.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode.startsWith('en')
                ? 'Font download failed'
                : 'فشل تحميل الخط',
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _deleteFont(QuranFont font) async {
    final fontService = ref.read(quranFontServiceProvider);
    final currentSettings = ref.read(mushafSettingsProvider);

    // If this font is currently selected, switch to default first
    if (currentSettings.selectedFontId == font.id) {
      ref.read(mushafSettingsProvider.notifier).setSelectedFont(QuranFont.uthmanicHafs.id);
    }

    final deleted = await fontService.deleteFont(font);
    if (deleted && mounted) {
      setState(() {
        _downloadedCache[font.id] = false;
        _loadedFonts.remove(font.id);
      });
    }
  }

  void _selectFont(QuranFont font) {
    ref.read(mushafSettingsProvider.notifier).setSelectedFont(font.id);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(mushafThemeProvider);
    final mushafSettings = ref.watch(mushafSettingsProvider);
    final isEnglish = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('en');

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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: currentTheme.textColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
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
                  isEnglish ? 'Quran Font' : 'خط المصحف',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.textColor,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Font List
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shrinkWrap: true,
              itemCount: QuranFont.all.length,
              itemBuilder: (context, index) {
                final font = QuranFont.all[index];
                final isSelected = mushafSettings.selectedFontId == font.id;
                final isDownloaded = _downloadedCache[font.id] ?? font.isBundled;
                final isDownloading = _downloadProgress.containsKey(font.id);
                final progress = _downloadProgress[font.id] ?? 0.0;

                return _buildFontTile(
                  font: font,
                  isSelected: isSelected,
                  isDownloaded: isDownloaded,
                  isDownloading: isDownloading,
                  progress: progress,
                  theme: currentTheme,
                  isEnglish: isEnglish,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFontTile({
    required QuranFont font,
    required bool isSelected,
    required bool isDownloaded,
    required bool isDownloading,
    required double progress,
    required MushafTheme theme,
    required bool isEnglish,
  }) {
    final canSelect = isDownloaded && !isDownloading;

    return GestureDetector(
      onTap: canSelect ? () => _selectFont(font) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.secondaryColor.withValues(alpha: 0.12)
              : theme.textColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.secondaryColor
                : theme.textColor.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: font name + action
            Row(
              children: [
                // Selected check
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsetsDirectional.only(end: 12),
                    decoration: BoxDecoration(
                      color: theme.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                // Font name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnglish ? font.nameEn : font.nameAr,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.textColor,
                        ),
                      ),
                      if (font.isBundled)
                        Text(
                          isEnglish ? 'Built-in' : 'مدمج',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: theme.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                ),
                // Action button
                _buildActionButton(
                  font: font,
                  isDownloaded: isDownloaded,
                  isDownloading: isDownloading,
                  progress: progress,
                  theme: theme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Preview text
            Text(
              font.preview,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: (isDownloaded && (_loadedFonts.contains(font.id) || font.isBundled))
                    ? font.fontFamily
                    : 'UthmanicHafs', // Fallback if not loaded yet
                fontSize: 24,
                height: 1.6,
                color: theme.textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required QuranFont font,
    required bool isDownloaded,
    required bool isDownloading,
    required double progress,
    required MushafTheme theme,
  }) {
    if (font.isBundled) {
      return const SizedBox.shrink();
    }

    if (isDownloading) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 2.5,
              color: theme.secondaryColor,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: theme.secondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    if (isDownloaded) {
      // Delete button
      return IconButton(
        icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
        onPressed: () => _showDeleteConfirmation(font),
        tooltip: 'Delete',
      );
    }

    // Download button
    return IconButton(
      icon: Icon(Icons.download_rounded, color: theme.secondaryColor, size: 26),
      onPressed: () => _downloadFont(font),
      tooltip: 'Download',
    );
  }

  void _showDeleteConfirmation(QuranFont font) {
    final isEnglish = Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('en');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEnglish ? 'Delete Font?' : 'حذف الخط؟'),
        content: Text(
          isEnglish
              ? 'Are you sure you want to delete "${font.nameEn}"?'
              : 'هل أنت متأكد من حذف خط "${font.nameAr}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEnglish ? 'Cancel' : 'إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteFont(font);
            },
            child: Text(
              isEnglish ? 'Delete' : 'حذف',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
