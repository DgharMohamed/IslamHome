import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MushafSettings {
  final double fontSizeScale;

  const MushafSettings({
    required this.fontSizeScale,
  });

  MushafSettings copyWith({
    double? fontSizeScale,
  }) {
    return MushafSettings(
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
    );
  }
}

final mushafSettingsProvider = NotifierProvider<MushafSettingsNotifier, MushafSettings>(
  MushafSettingsNotifier.new,
);

class MushafSettingsNotifier extends Notifier<MushafSettings> {
  static const String _boxName = 'settings';
  static const String _fontSizeKey = 'mushaf_font_size_scale';
  late Box _box;

  @override
  MushafSettings build() {
    _box = Hive.box(_boxName);
    final fontSizeScale = _box.get(_fontSizeKey, defaultValue: 1.0) as double;
    
    return MushafSettings(
      fontSizeScale: fontSizeScale,
    );
  }

  void setFontSizeScale(double scale) {
    state = state.copyWith(fontSizeScale: scale);
    _box.put(_fontSizeKey, scale);
  }
}
