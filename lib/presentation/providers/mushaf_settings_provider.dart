import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/quran_font_model.dart';

class MushafSettings {
  final double fontSizeScale;
  final String selectedFontId;

  const MushafSettings({
    required this.fontSizeScale,
    required this.selectedFontId,
  });

  MushafSettings copyWith({double? fontSizeScale, String? selectedFontId}) {
    return MushafSettings(
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      selectedFontId: selectedFontId ?? this.selectedFontId,
    );
  }

  /// Returns the QuranFont object for the current selection.
  QuranFont get selectedFont => QuranFont.fromId(selectedFontId);
}

final mushafSettingsProvider =
    NotifierProvider<MushafSettingsNotifier, MushafSettings>(
      MushafSettingsNotifier.new,
    );

class MushafSettingsNotifier extends Notifier<MushafSettings> {
  static const String _boxName = 'settings';
  static const String _fontSizeKey = 'mushaf_font_size_scale';
  static const String _fontIdKey = 'mushaf_selected_font_id';
  late Box _box;

  @override
  MushafSettings build() {
    _box = Hive.box(_boxName);
    final fontSizeScale = _box.get(_fontSizeKey, defaultValue: 1.0) as double;
    final fontId = _box.get(_fontIdKey, defaultValue: QuranFont.uthmanicHafs.id) as String;

    return MushafSettings(
      fontSizeScale: fontSizeScale,
      selectedFontId: fontId,
    );
  }

  void setFontSizeScale(double scale) {
    state = state.copyWith(fontSizeScale: scale);
    _box.put(_fontSizeKey, scale);
  }

  void setSelectedFont(String fontId) {
    state = state.copyWith(selectedFontId: fontId);
    _box.put(_fontIdKey, fontId);
  }
}

