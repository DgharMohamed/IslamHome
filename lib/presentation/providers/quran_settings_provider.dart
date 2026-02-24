import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';

/// Notifier to manage the currently selected reciter for Quran playback.
class SelectedReciterNotifier extends Notifier<Reciter?> {
  @override
  Reciter? build() {
    final recitersAsync = ref.watch(recitersProvider);
    return recitersAsync.maybeWhen(
      data: (reciters) => reciters.isNotEmpty ? reciters.first : null,
      orElse: () => null,
    );
  }

  void setReciter(Reciter reciter) {
    state = reciter;
  }
}

/// Provider to store the currently selected reciter for Quran playback.
final selectedReciterProvider =
    NotifierProvider<SelectedReciterNotifier, Reciter?>(
      SelectedReciterNotifier.new,
    );

/// Notifier to manage the visibility of Juz transition markers in Quran text.
class ShowJuzMarkersNotifier extends Notifier<bool> {
  @override
  bool build() {
    final box = Hive.box('settings');
    return box.get('show_juz_markers', defaultValue: true);
  }

  Future<void> toggle(bool value) async {
    state = value;
    final box = Hive.box('settings');
    await box.put('show_juz_markers', value);
  }
}

/// Provider for Juz marker visibility setting.
final showJuzMarkersProvider = NotifierProvider<ShowJuzMarkersNotifier, bool>(
  ShowJuzMarkersNotifier.new,
);

/// Notifier to manage the font size of Quranic text.
class QuranFontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    final box = Hive.box('settings');
    return box.get('quran_font_size', defaultValue: 28.0);
  }

  Future<void> updateSize(double size) async {
    state = size.clamp(20.0, 50.0);
    final box = Hive.box('settings');
    await box.put('quran_font_size', state);
  }
}

final quranFontSizeProvider = NotifierProvider<QuranFontSizeNotifier, double>(
  QuranFontSizeNotifier.new,
);

/// Notifier to manage the font size of translation text.
class TranslationFontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    final box = Hive.box('settings');
    return box.get('translation_font_size', defaultValue: 14.0);
  }

  Future<void> updateSize(double size) async {
    state = size.clamp(12.0, 24.0);
    final box = Hive.box('settings');
    await box.put('translation_font_size', state);
  }
}

final translationFontSizeProvider =
    NotifierProvider<TranslationFontSizeNotifier, double>(
      TranslationFontSizeNotifier.new,
    );

/// Notifier to manage the auto-scroll setting for synchronized Quran audio.
class AutoScrollToAyahNotifier extends Notifier<bool> {
  @override
  bool build() {
    final box = Hive.box('settings');
    return box.get('auto_scroll_to_ayah', defaultValue: true);
  }

  Future<void> toggle(bool value) async {
    state = value;
    final box = Hive.box('settings');
    await box.put('auto_scroll_to_ayah', value);
  }
}

/// Provider for auto-scroll setting.
final autoScrollToAyahProvider =
    NotifierProvider<AutoScrollToAyahNotifier, bool>(
      AutoScrollToAyahNotifier.new,
    );
