import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/quran_content_model.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';

enum FlowItemType { surahHeader, block }

class FlowItem {
  final FlowItemType type;
  final int surahNumber;
  final String? surahName;
  final List<Ayah>? ayahs;
  final List<Ayah>? translationAyahs;
  final int blockIndex;

  FlowItem({
    required this.type,
    required this.surahNumber,
    this.surahName,
    this.ayahs,
    this.translationAyahs,
    this.blockIndex = 0,
  });
}

class QuranFlowState {
  final List<FlowItem> items;
  final Set<int> loadedSurahs;
  final bool isLoading;

  QuranFlowState({
    this.items = const [],
    this.loadedSurahs = const {},
    this.isLoading = false,
  });

  QuranFlowState copyWith({
    List<FlowItem>? items,
    Set<int>? loadedSurahs,
    bool? isLoading,
  }) {
    return QuranFlowState(
      items: items ?? this.items,
      loadedSurahs: loadedSurahs ?? this.loadedSurahs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuranFlowNotifier extends Notifier<QuranFlowState> {
  @override
  QuranFlowState build() {
    // Initial state is empty
    return QuranFlowState();
  }

  static const int _blockSize = 50;

  Future<void> loadInitialSurah(
    int surahNumber, {
    required String translation,
  }) async {
    // Reset state before loading new surah to ensure we jump to the right place
    state = QuranFlowState(isLoading: true);

    // Load ONLY the requested surah first to ensure it's at index 0
    await _loadSurah(surahNumber, translation: translation);

    // Pre-load ONLY the next surah to avoid shifting the view with prepended items
    if (surahNumber < 114) {
      await _loadSurah(surahNumber + 1, translation: translation);
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadSurah(
    int surahNumber, {
    required String translation,
  }) async {
    if (state.loadedSurahs.contains(surahNumber)) return;

    final quranService = ref.read(quranServiceProvider);
    final arabicContent = await quranService.getQuranSurah(surahNumber);
    final translationContent = await quranService.getQuranSurah(
      surahNumber,
      edition: translation,
    );

    if (arabicContent == null || arabicContent.ayahs == null) return;

    final List<FlowItem> newItems = [];

    // 1. Add Header
    newItems.add(
      FlowItem(
        type: FlowItemType.surahHeader,
        surahNumber: surahNumber,
        surahName: arabicContent.name,
      ),
    );

    // 2. Add Blocks
    final ayahs = arabicContent.ayahs!;
    final transAyahs = translationContent?.ayahs ?? [];

    for (int i = 0; i < ayahs.length; i += _blockSize) {
      final end = (i + _blockSize).clamp(0, ayahs.length);
      newItems.add(
        FlowItem(
          type: FlowItemType.block,
          surahNumber: surahNumber,
          blockIndex: i ~/ _blockSize,
          ayahs: ayahs.sublist(i, end),
          translationAyahs: transAyahs.length > i
              ? transAyahs.sublist(
                  i,
                  (i + _blockSize).clamp(0, transAyahs.length),
                )
              : null,
        ),
      );
    }

    // Merge logic: keep items sorted by surah number
    final List<FlowItem> mergedItems = List.from(state.items);
    mergedItems.addAll(newItems);
    mergedItems.sort((a, b) {
      if (a.surahNumber != b.surahNumber) {
        return a.surahNumber.compareTo(b.surahNumber);
      }
      if (a.type != b.type) {
        return a.type == FlowItemType.surahHeader ? -1 : 1;
      }
      return a.blockIndex.compareTo(b.blockIndex);
    });

    state = state.copyWith(
      items: mergedItems,
      loadedSurahs: {...state.loadedSurahs, surahNumber},
    );
  }

  Future<void> ensureSurahVisible(
    int surahNumber, {
    required String translation,
  }) async {
    if (!state.loadedSurahs.contains(surahNumber)) {
      await _loadSurah(surahNumber, translation: translation);
    }
    // Pre-load neighbors as we move
    if (surahNumber > 1 && !state.loadedSurahs.contains(surahNumber - 1)) {
      _loadSurah(surahNumber - 1, translation: translation); // Background
    }
    if (surahNumber < 114 && !state.loadedSurahs.contains(surahNumber + 1)) {
      _loadSurah(surahNumber + 1, translation: translation); // Background
    }
  }
}

final quranFlowProvider = NotifierProvider<QuranFlowNotifier, QuranFlowState>(
  () {
    return QuranFlowNotifier();
  },
);
