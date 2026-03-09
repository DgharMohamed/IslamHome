import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/data/models/quran_page_model.dart';

class QuranPageWidget extends ConsumerWidget {
  final int pageNumber;

  const QuranPageWidget({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(quranPageProvider(pageNumber));
    final activeVerseKey = ref.watch(activeVerseKeyProvider);

    return pageAsync.when(
      data: (page) => _buildPage(context, ref, page, activeVerseKey),
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC9A227),
          strokeWidth: 2,
        ),
      ),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading page $pageNumber',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref,
    QuranPage page,
    String? activeVerseKey,
  ) {
    return Container(
      color: const Color(0xFF121212),
      child: Column(
        children: [
          _buildHeader(page),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: page.lines
                    .map((line) => _buildLine(ref, line, activeVerseKey))
                    .toList(),
              ),
            ),
          ),
          _buildFooter(page),
        ],
      ),
    );
  }

  Widget _buildHeader(QuranPage page) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8E3D6).withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'الجزء ${page.juzNumber}',
            style: const TextStyle(
              color: Color(0xFFC9A227),
              fontSize: 14,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            page.surahName,
            style: const TextStyle(
              color: Color(0xFFE8E3D6),
              fontSize: 20,
              fontFamily: 'UthmanicHafs',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(QuranPage page) {
    return Container(
      height: 50,
      alignment: Alignment.topCenter,
      child: Text(
        '${page.pageNumber}',
        style: const TextStyle(
          color: Color(0xFFC9A227),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildLine(WidgetRef ref, QuranLine line, String? activeVerseKey) {
    return Expanded(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (line.words.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: line.words
                        .map((word) => _buildWord(ref, word, activeVerseKey))
                        .toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWord(WidgetRef ref, QuranWord word, String? activeVerseKey) {
    final bool isEnd = word.charTypeName == 'end';
    final bool isActive = activeVerseKey == word.verseKey;

    if (isEnd) {
      return _buildAyahNumber(word.textUthmani, isActive);
    }

    return GestureDetector(
      onTap: () {
        ref.read(activeVerseKeyProvider.notifier).setActive(word.verseKey);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFC9A227).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          word.textUthmani,
          style: TextStyle(
            color: isActive ? const Color(0xFFC9A227) : const Color(0xFFE8E3D6),
            fontSize: 24,
            fontFamily: 'UthmanicHafs',
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahNumber(String marker, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? const Color(0xFFC9A227)
              : const Color(0xFFC9A227).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        marker,
        style: const TextStyle(
          color: Color(0xFFC9A227),
          fontSize: 14,
          fontFamily: 'UthmanicHafs',
        ),
      ),
    );
  }
}
