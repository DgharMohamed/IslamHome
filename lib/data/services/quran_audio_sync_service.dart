import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:islam_home/data/models/ayah_timing.dart';
import 'package:islam_home/data/models/reciter_model.dart';
import 'package:islam_home/data/models/quran_media_item.dart';
import 'package:islam_home/data/models/quran_content_model.dart';

class QuranAudioSyncService {
  final Dio _dio;

  // Mapping of reciter names to timing folder names on everyayah.com
  static const Map<String, String> _reciterTimingFolderMap = {
    'عبد الباسط عبد الصمد': 'Abdul_Basit_Murattal_Timings',
    'عبد الباسط عبد الصمد مجود': 'Abdul_Basit_Mujawwad',
    'محمد صديق المنشاوي': 'Minshawy Murattal',
    'مشاري العفاسي': 'Alafasy_128kbps',
    'خليل الحصري': 'Husary_Timings',
    'الحذيفي': 'Hudhaify_128kbps_Timings',
    'ناصر القطامي': 'Nasser_Alqatami_128kbps',
    'أحمد بن علي العجمي': 'ahmed_ibn_ali_al_ajamy_128kbps',
    'ماهر المعيقلي': 'Maher_AlMuaiqly_64kbps',
    'سعد الغامدي': 'Ghamadi_40kbps',
    'عبد الرحمن السديس': 'Sudais',
    'سعود الشريم': 'Saud Ash Shuraym',
    'ياسر الدوسري': 'Yasser_Ad-Dussary_128kbps',
    'محمد أيوب': 'Muhammad Ayyoob bin Muhammad Yoosuf Timings',
  };

  // Mapping of reciter names to audio folder names on everyayah.com
  static const Map<String, String> _reciterAudioFolderMap = {
    'عبد الباسط عبد الصمد': 'Abdul_Basit_Murattal_64kbps',
    'عبد الباسط عبد الصمد مجود': 'Abdul_Basit_Mujawwad_128kbps',
    'محمد صديق المنشاوي': 'Minshawy_Murattal_128kbps',
    'مشاري العفاسي': 'Alafasy_128kbps',
    'خليل الحصري': 'Husary_128kbps',
    'الحذيفي': 'Hudhaify_128kbps',
    'ناصر القطامي': 'Nasser_Alqatami_128kbps',
    'أحمد بن علي العجمي': 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net',
    'ماهر المعيقلي': 'Maher_AlMuaiqly_64kbps',
    'سعد الغامدي': 'Ghamadi_40kbps',
    'عبد الرحمن السديس': 'Abdurrahmaan_As-Sudais_192kbps',
    'سعود الشريم': 'Saud_Ash-Shuraym_128kbps',
    'ياسر الدوسري': 'Yasser_Ad-Dussary_128kbps',
    'محمد أيوب': 'Muhammad_Ayyoob_128kbps',
  };

  List<AyahTiming> _currentTimings = [];
  final _currentAyahController = StreamController<int?>.broadcast();

  QuranAudioSyncService(this._dio);

  Stream<int?> get currentAyahStream => _currentAyahController.stream;

  /// Fetches timing data for a specific surah and reciter.
  Future<void> loadTimings(Reciter reciter, int surahNumber) async {
    try {
      final folder = _getTimingFolderForReciter(reciter);
      if (folder == null) {
        _currentTimings = [];
        _currentAyahController.add(null);
        return;
      }

      final surahStr = surahNumber.toString().padLeft(3, '0');
      final url =
          'https://everyayah.com/data/timings_files/$folder/$surahStr.txt';

      debugPrint('🎵 Sync: Fetching timings from $url');
      final response = await _dio.get<String>(url);

      if (response.statusCode == 200 && response.data != null) {
        _currentTimings = _parseTimingFile(response.data!, surahNumber);
        debugPrint(
          '🎵 Sync: Loaded ${_currentTimings.length} ayahs for surah $surahNumber',
        );
      } else {
        _currentTimings = [];
        _currentAyahController.add(null);
      }
    } catch (e) {
      debugPrint('🎵 Sync: Error loading timings: $e');
      _currentTimings = [];
      _currentAyahController.add(null);
    }
  }

  /// Updates the current active ayah based on the player position.
  /// (Useful for tracking progress even in playlist mode)
  void updatePosition(Duration position) {
    if (_currentTimings.isEmpty) return;

    final ms = position.inMilliseconds;
    int? activeAyah;

    for (int i = 0; i < _currentTimings.length; i++) {
      final current = _currentTimings[i];
      final next = (i + 1 < _currentTimings.length)
          ? _currentTimings[i + 1]
          : null;

      if (ms >= current.startTimeMs &&
          (next == null || ms < next.startTimeMs)) {
        activeAyah = current.ayahNumber;
        break;
      }
    }

    _currentAyahController.add(activeAyah);
  }

  /// Finds the seek time for a specific ayah.
  Duration? getSeekTime(int ayahNumber) {
    try {
      final timing = _currentTimings.firstWhere(
        (t) => t.ayahNumber == ayahNumber,
      );
      return Duration(milliseconds: timing.startTimeMs);
    } catch (_) {
      return null;
    }
  }

  /// Generates a list of QuranVerse objects for an entire surah.
  List<QuranVerse> getVersesForSurah({
    required int surahNumber,
    required String surahName,
    required List<Ayah> ayahs,
    required Reciter reciter,
    List<Ayah>? translationAyahs,
  }) {
    final audioFolder = _getAudioFolderForReciter(reciter);
    if (audioFolder == null) return [];

    final List<QuranVerse> verses = [];
    final surahPadded = surahNumber.toString().padLeft(3, '0');

    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      final numInSurah = ayah.numberInSurah ?? (i + 1);
      final ayahPadded = numInSurah.toString().padLeft(3, '0');

      final audioUrl =
          'https://everyayah.com/data/$audioFolder/$surahPadded$ayahPadded.mp3';
      final translation =
          (translationAyahs != null && translationAyahs.length > i)
          ? translationAyahs[i].text
          : null;

      verses.add(
        QuranVerse(
          surahNumber: surahNumber,
          surahName: surahName,
          verseNumber: numInSurah,
          arabicText: ayah.text ?? '',
          audioUrl: audioUrl,
          duration: Duration.zero, // Duration discovered at runtime by player
          translation: translation,
        ),
      );
    }

    return verses;
  }

  String? _getTimingFolderForReciter(Reciter reciter) {
    return _getFolderFromMap(reciter, _reciterTimingFolderMap);
  }

  String? _getAudioFolderForReciter(Reciter reciter) {
    return _getFolderFromMap(reciter, _reciterAudioFolderMap);
  }

  String? _getFolderFromMap(Reciter reciter, Map<String, String> folderMap) {
    final name = reciter.name;
    if (name == null) return null;

    // Direct match
    if (folderMap.containsKey(name)) {
      return folderMap[name];
    }

    // Partial match
    for (final entry in folderMap.entries) {
      if (name.contains(entry.key) || entry.key.contains(name)) {
        return entry.value;
      }
    }

    return null;
  }

  List<AyahTiming> _parseTimingFile(String content, int surahNumber) {
    final List<AyahTiming> timings = [];
    final lines = content
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      final timeMs = int.tryParse(lines[i].trim());
      if (timeMs != null) {
        timings.add(
          AyahTiming(
            surahNumber: surahNumber,
            ayahNumber: i + 1,
            startTimeMs: timeMs,
          ),
        );
      }
    }
    return timings;
  }

  void dispose() {
    _currentAyahController.close();
  }
}
