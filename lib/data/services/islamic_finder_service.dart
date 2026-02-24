import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/models/prayer_time.dart';

class IslamicFinderService {
  final Dio _dio = Dio();
  final Box _cacheBox = Hive.box('prayer_times_cache');

  /// Fetches timings for a specific geonameId.
  /// Example geonameId: 2530335 for Tangier.
  Future<DailyPrayerTimes?> getTodayTimings(
    String geonameId, {
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    final cacheKey =
        'islamicfinder_${geonameId}_${now.year}_${now.month}_${now.day}';

    // 1. Try Cache
    if (!forceRefresh) {
      final cachedMap = _cacheBox.get(cacheKey);
      if (cachedMap != null && cachedMap is Map) {
        return DailyPrayerTimes.fromJson(Map<String, dynamic>.from(cachedMap));
      }
    }

    // 2. Fetch from IslamicFinder
    final url =
        'https://www.islamicfinder.org/world/morocco/$geonameId/city-prayer-times/?language=ar';

    try {
      debugPrint(
        'IslamicFinder: Fetching fresh timings for geonameId $geonameId',
      );
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      if (response.statusCode == 200) {
        final document = parser.parse(response.data.toString());

        // Extracting from OG Description as it's very reliable on IslamicFinder
        // Content example: "الفجر: 06:46 AM الظهر: 01:38 PM العصر: 04:39 PM المغرب: 07:03 PM العشاء: 08:25 PM"
        final ogDescription = document
            .querySelector('meta[property="og:description"]')
            ?.attributes['content'];

        if (ogDescription != null) {
          final timings = _parseOgDescription(ogDescription);
          if (timings.isNotEmpty) {
            final daily = DailyPrayerTimes(
              timings: timings,
              date: '${now.day}-${now.month}-${now.year}',
              hijriDate: '', // Can be extracted if needed
              dayName: '', // Can be extracted if needed
              cityId: geonameId,
              cityName: document.querySelector('h1')?.text.trim() ?? 'Unknown',
            );

            await _cacheBox.put(cacheKey, daily.toJson());
            return daily;
          }
        }
      }
    } catch (e) {
      debugPrint('IslamicFinder Critical Error: $e');
    }

    return null;
  }

  Map<String, String> _parseOgDescription(String desc) {
    final Map<String, String> timings = {};

    // Regex to match "TimeName: HH:MM AM/PM"
    // Note: IslamicFinder uses Arabic names in the desc for Arabic language
    final Map<String, List<String>> patterns = {
      'Fajr': ['الفجر', 'Fajr'],
      'Sunrise': ['الشروق', 'Sunrise'],
      'Dhuhr': ['الظهر', 'Dhuhr'],
      'Asr': ['العصر', 'Asr'],
      'Maghrib': ['المغرب', 'Maghrib'],
      'Isha': ['العشاء', 'Isha'],
    };

    for (var entry in patterns.entries) {
      for (var pattern in entry.value) {
        final reg = RegExp('$pattern:\\s*(\\d{2}:\\d{2}\\s*[AP]M)');
        final match = reg.firstMatch(desc);
        if (match != null) {
          timings[entry.key] = match.group(1)!;
          break;
        }
      }
    }

    return timings;
  }
}
