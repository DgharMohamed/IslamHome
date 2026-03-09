import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MushafTheme {
  final String id;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color highlightColor;
  final Color secondaryColor;

  const MushafTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.highlightColor,
    required this.secondaryColor,
  });

  static const List<MushafTheme> themes = [
    MushafTheme(
      id: 'cream',
      name: 'كريمي',
      backgroundColor: Color(0xFFFDF7F0),
      textColor: Color(0xFF2D2D2D),
      highlightColor: Color(0xFFFFECB3),
      secondaryColor: Color(0xFFC9A84C),
    ),
    MushafTheme(
      id: 'green',
      name: 'أخضر',
      backgroundColor: Color(0xFFE8F5E9),
      textColor: Color(0xFF1B5E20),
      highlightColor: Color(0xFFC8E6C9),
      secondaryColor: Color(0xFF2E7D32),
    ),
    MushafTheme(
      id: 'blue',
      name: 'أزرق',
      backgroundColor: Color(0xFFE1F5FE),
      textColor: Color(0xFF01579B),
      highlightColor: Color(0xFFB3E5FC),
      secondaryColor: Color(0xFF0288D1),
    ),
    MushafTheme(
      id: 'sepia',
      name: 'ورق قديم',
      backgroundColor: Color(0xFFF4ECD8),
      textColor: Color(0xFF5D4037),
      highlightColor: Color(0xFFE0D4B8),
      secondaryColor: Color(0xFF8D6E63),
    ),
    MushafTheme(
      id: 'dark',
      name: 'ليلي',
      backgroundColor: Color(0xFF1A1C1E),
      textColor: Color(0xFFE2E2E6),
      highlightColor: Color(0xFF333537),
      secondaryColor: Color(0xFFC9A84C),
    ),
    MushafTheme(
      id: 'black',
      name: 'أسود',
      backgroundColor: Color(0xFF000000),
      textColor: Color(0xFFFFFFFF),
      highlightColor: Color(0xFF1A1A1A),
      secondaryColor: Color(0xFFFFD700),
    ),
  ];
}

final mushafThemeProvider = NotifierProvider<MushafThemeNotifier, MushafTheme>(
  MushafThemeNotifier.new,
);

class MushafThemeNotifier extends Notifier<MushafTheme> {
  static const String _key = 'selected_mushaf_theme';
  late Box _box;

  @override
  MushafTheme build() {
    _box = Hive.box('settings');
    final id = _box.get(_key, defaultValue: 'cream');
    return MushafTheme.themes.firstWhere(
      (t) => t.id == id,
      orElse: () => MushafTheme.themes[0],
    );
  }

  void setTheme(String id) {
    final theme = MushafTheme.themes.firstWhere((t) => t.id == id);
    state = theme;
    _box.put(_key, id);
  }
}
