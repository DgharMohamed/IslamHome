import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:islam_home/data/services/tafsir_download_service.dart';

class QuranApiService {
  final Dio _dio;

  static const String _quranComBaseUrl = 'https://api.quran.com/api/v4';
  static const String _quraniGeneralBaseUrl = 'https://api.qurani.ai/gw/qh/v1';
  static const String _quranpediaBaseUrl = 'https://api.quranpedia.net/v1';
  static const String _fawazQuranBaseUrl =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/quran-api@1';
  static const String _defaultPrimaryTafsirEdition = 'ara-jalaladdinalmah';
  static const List<String> _fallbackTafsirEditions = <String>[
    'ara-jalaladdinalmah',
    'ara-sirajtafseer',
    'ara-sirajtafseernod',
    'qurancom-14',
    'qurancom-91',
    'qurancom-15',
    'qurancom-90',
    'qurancom-94',
    'qurancom-16',
    'qurancom-93',
    'eng-almuntakhabfita',
    'eng-abulalamaududi',
    'eng-maududi',
    'ind-jalaladdinalmah',
    'tur-ibnikesir',
    'urd-abulaalamaududi',
  ];
  static const List<String> _tafsirDetectionKeywords = <String>[
    'tafsir',
    'tafseer',
    'jalaladdinalmah',
    'maududi',
    'ibnikesir',
    'ibn kathir',
    'ibn-kathir',
    'almuntakhab',
    'muntakhab',
    'qurtubi',
    'tabari',
    'muyassar',
    'mukhtasar',
    'mokhtasar',
  ];
  static const Map<String, String> _tafsirSourceLabels = <String, String>{
    'ara-jalaladdinalmah': 'تفسير الجلالين',
    'ara-sirajtafseer': 'تفسير السراج (مشكول)',
    'ara-sirajtafseernod': 'تفسير السراج (بدون تشكيل)',
    'qurancom-14': 'تفسير ابن كثير',
    'qurancom-91': 'تفسير السعدي',
    'qurancom-15': 'تفسير الطبري',
    'qurancom-90': 'تفسير القرطبي',
    'qurancom-94': 'تفسير البغوي',
    'qurancom-16': 'التفسير الميسر',
    'qurancom-93': 'التفسير الوسيط (طنطاوي)',
    'eng-almuntakhabfita': 'Almuntakhab Fi Tafsir (EN)',
    'eng-abulalamaududi': 'Tafhim al-Quran - Maududi (EN)',
    'eng-maududi': 'Maududi Tafsir (EN)',
    'ind-jalaladdinalmah': 'Tafsir al-Jalalayn (ID)',
    'tur-ibnikesir': 'Ibn Kathir (TR)',
    'urd-abulaalamaududi': 'Tafhim al-Quran - Maududi (UR)',
  };
  static const String _offlineEnglishTranslationAsset =
      'assets/data/quran/en.sahih.json';
  static const String _offlineArabicTranslationAsset =
      'assets/data/quran/quran-uthmani.json';
  // Heavy tafsir packs are now expected to be downloaded on-demand and stored
  // locally via TafsirDownloadService instead of being bundled in the APK.
  static const Map<String, String> _offlineTafsirAssetBySource =
      <String, String>{};

  static final Map<String, _ApiCacheEntry> _memoryCache = {};
  static final Map<String, Map<String, String>> _offlineVerseTextCache = {};
  static final Map<String, Future<Map<String, String>>>
  _offlineVerseTextLoaders = {};

  QuranApiService(this._dio) {
    _dio.options = _dio.options.copyWith(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 8),
      headers: {..._dio.options.headers, 'Accept': 'application/json'},
    );
  }

  Future<dynamic> _safeGetData(
    String url, {
    Map<String, dynamic>? queryParameters,
    Duration? ttl,
    bool forceRefresh = false,
    int retries = 2,
  }) async {
    final normalizedQuery = _normalizedQuery(queryParameters);
    final cacheKey = _buildCacheKey(url, normalizedQuery);

    if (!forceRefresh && ttl != null) {
      final cached = _memoryCache[cacheKey];
      if (cached != null && !cached.isExpired) {
        return cached.data;
      }
    }

    DioException? lastError;
    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        final response = await _dio.get(url, queryParameters: normalizedQuery);
        final status = response.statusCode ?? 0;
        if (status < 200 || status >= 300) {
          throw DioException.badResponse(
            statusCode: status,
            requestOptions: response.requestOptions,
            response: response,
          );
        }

        if (ttl != null) {
          _memoryCache[cacheKey] = _ApiCacheEntry(
            data: response.data,
            expiresAt: DateTime.now().add(ttl),
          );
        }
        return response.data;
      } on DioException catch (e) {
        lastError = e;
        if (!_shouldRetry(e) || attempt == retries) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 250 * (attempt + 1)));
      }
    }

    throw lastError ?? Exception('Request failed for $url');
  }

  Map<String, dynamic>? _normalizedQuery(
    Map<String, dynamic>? queryParameters,
  ) {
    if (queryParameters == null) return null;
    final cleaned = <String, dynamic>{};
    queryParameters.forEach((key, value) {
      if (value != null) {
        cleaned[key] = value;
      }
    });
    return cleaned.isEmpty ? null : cleaned;
  }

  String _buildCacheKey(String url, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return url;
    final keys = queryParameters.keys.toList()..sort();
    final query = keys.map((k) => '$k=${queryParameters[k]}').join('&');
    return '$url?$query';
  }

  bool _shouldRetry(DioException error) {
    final type = error.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.unknown) {
      return true;
    }

    final status = error.response?.statusCode;
    if (status == null) return false;
    return status == 429 || status >= 500;
  }

  Future<Map<String, dynamic>> getPageData(int pageNumber) async {
    final data = await _safeGetData(
      '$_quranComBaseUrl/verses/by_page/$pageNumber',
      queryParameters: {
        'language': 'ar',
        'words': 'true',
        'word_fields': 'text_uthmani,position,id,line_number,char_type_name',
        'fields':
            'text_uthmani,chapter_id,verse_number,verse_key,juz_number,hizb_number,page_number',
      },
      ttl: const Duration(minutes: 20),
    );
    return _asMap(data);
  }

  Future<Map<String, dynamic>> getPageAudio(
    int pageNumber,
    int reciterId,
  ) async {
    final data = await _safeGetData(
      '$_quranComBaseUrl/recitations/$reciterId/by_page/$pageNumber',
      ttl: const Duration(minutes: 20),
    );
    return _asMap(data);
  }

  Future<String> getVerseTranslation(
    int surah,
    int ayah, {
    String languageCode = 'ar',
  }) async {
    final isArabic = languageCode.toLowerCase().startsWith('ar');
    final offlineText = await _getOfflineTranslationText(
      surah: surah,
      ayah: ayah,
      isArabic: isArabic,
    );
    if (offlineText.isNotEmpty) {
      return offlineText;
    }

    final editions = isArabic
        ? const <String>[
            'ara-jalaladdinalmah',
            'ara-sirajtafseer',
            'ara-kingfahadquranc',
          ]
        : const <String>[
            'eng-ummmuhammad',
            'eng-mustafakhattab',
            'eng-abdelhaleem',
          ];

    final text = await _getFawazVerseText(
      surah: surah,
      ayah: ayah,
      editions: editions,
    );

    if (text.isNotEmpty) return text;
    return isArabic
        ? 'تعذر جلب النص من Quran API حالياً.'
        : 'Failed to load verse translation from Quran API.';
  }

  Future<String> getVerseTafsir(int surah, int ayah) async {
    return getVerseTafsirBySource(
      surah,
      ayah,
      sourceId: _defaultPrimaryTafsirEdition,
    );
  }

  Future<String> getVerseTafsirBySource(
    int surah,
    int ayah, {
    required String sourceId,
  }) async {
    // 1. Check local offline storage first
    try {
      final downloadService = TafsirDownloadService();
      if (await downloadService.isTafsirDownloaded(sourceId)) {
        final offlineText = await downloadService.getTafsirFromLocal(
          sourceId,
          surah,
          ayah,
        );
        if (offlineText != null && offlineText.isNotEmpty) {
          return offlineText;
        }
      }
    } catch (e) {
      debugPrint('Error reading offline tafsir: $e');
    }

    // 2. Built-in bundled offline tafsir fallback
    final bundledTafsir = await _getBundledOfflineTafsir(
      sourceId: sourceId,
      surah: surah,
      ayah: ayah,
    );
    if (bundledTafsir.isNotEmpty) {
      return bundledTafsir;
    }

    // 3. Fallback to API if not downloaded or bundled
    if (sourceId.startsWith('qurancom-')) {
      final quranComId = int.tryParse(sourceId.split('-').last);
      if (quranComId != null) {
        final text = await _getQuranComVerseTafsir(surah, ayah, quranComId);
        if (text.isNotEmpty) return text;
      }
    } else {
      final text = await _getFawazVerseText(
        surah: surah,
        ayah: ayah,
        editions: <String>[sourceId],
      );
      if (text.isNotEmpty) return text;
    }
    return sourceId.startsWith('eng-')
        ? 'No tafsir text is available from this source for this verse.'
        : 'لا يوجد نص تفسير متاح من هذا المصدر لهذه الآية.';
  }

  Future<String> _getQuranComVerseTafsir(
    int surah,
    int ayah,
    int sourceId,
  ) async {
    try {
      final data = await _safeGetData(
        '$_quranComBaseUrl/tafsirs/$sourceId/by_ayah/$surah:$ayah',
        ttl: const Duration(hours: 8),
      );
      final map = _asMap(data);
      if (map.containsKey('tafsir')) {
        final tafsirInner = _asMap(map['tafsir']);
        return _cleanText(tafsirInner['text']?.toString());
      } else if (map.containsKey('tafsirs') && map['tafsirs'] is List) {
        final list = map['tafsirs'] as List;
        if (list.isNotEmpty && list.first is Map) {
          final first = list.first as Map;
          return _cleanText(first['text']?.toString());
        }
      }
    } catch (e) {
      debugPrint('QuranCom Tafsir error: $e');
    }
    return '';
  }

  Future<List<Map<String, String>>> getTafsirSources({
    bool forceRefresh = false,
    bool arabicOnly = false,
    bool englishOnly = false,
    bool arabicTitles = false,
  }) async {
    final byId = <String, Map<String, String>>{};
    Map<String, dynamic> editionsMap = const {};

    try {
      final data = await _safeGetData(
        '$_fawazQuranBaseUrl/editions.min.json',
        ttl: const Duration(hours: 12),
        forceRefresh: forceRefresh,
      ).timeout(const Duration(seconds: 2));
      editionsMap = _asMap(data);
    } catch (_) {}

    if (editionsMap.isNotEmpty) {
      for (final entry in editionsMap.entries) {
        final rawMeta = entry.value;
        if (rawMeta is! Map) continue;
        final meta = rawMeta.cast<String, dynamic>();

        final idFromMeta = _cleanText(meta['name']?.toString());
        final id = idFromMeta.isNotEmpty
            ? idFromMeta
            : entry.key.replaceAll('_', '-');
        if (_isLatinEditionVariant(id)) continue;

        final author = _cleanText(meta['author']?.toString());
        final language = _cleanText(meta['language']?.toString());
        final source = _cleanText(meta['source']?.toString());
        final isArabicEdition = _isArabicEdition(id, language);
        if (arabicOnly && !isArabicEdition) continue;
        final isEnglishEdition = _isEnglishEdition(id, language);
        if (englishOnly && !isEnglishEdition) continue;
        if (!_looksLikeTafsirEdition(
          id: id,
          author: author,
          language: language,
          source: source,
        )) {
          continue;
        }

        final mappedName = _tafsirSourceLabels[id];
        final name = arabicTitles
            ? mappedName
            : (mappedName ?? _humanizeEditionName(id, language: language));
        if (name == null || name.isEmpty) continue;
        if (arabicTitles && !_containsArabicLetters(name)) continue;
        byId[id] = <String, String>{
          'id': id,
          'name': name,
          if (author.isNotEmpty) 'author': author,
          if (language.isNotEmpty) 'language': language,
        };
      }
    }

    for (final edition in _fallbackTafsirEditions) {
      if (arabicOnly &&
          !edition.startsWith('ara-') &&
          !edition.startsWith('qurancom-')) {
        continue;
      }
      if (englishOnly && !edition.startsWith('eng-')) {
        continue;
      }
      byId.putIfAbsent(edition, () {
        final key = edition.replaceAll('-', '_');
        final raw = editionsMap[key];
        final meta = raw is Map ? raw.cast<String, dynamic>() : const {};
        final author = _cleanText(meta['author']?.toString());
        final language = _cleanText(meta['language']?.toString());
        final mappedName = _tafsirSourceLabels[edition];
        final name = arabicTitles
            ? mappedName
            : (mappedName ?? _humanizeEditionName(edition, language: language));
        if (name == null || name.isEmpty) {
          return <String, String>{
            'id': edition,
            'name': edition,
            if (author.isNotEmpty) 'author': author,
            if (language.isNotEmpty) 'language': language,
          };
        }
        if (arabicTitles && !_containsArabicLetters(name)) {
          return <String, String>{};
        }
        return <String, String>{
          'id': edition,
          'name': name,
          if (author.isNotEmpty) 'author': author,
          if (language.isNotEmpty) 'language': language,
        };
      });
    }

    final sources =
        byId.values
            .where(
              (e) => (e['id'] ?? '').isNotEmpty && (e['name'] ?? '').isNotEmpty,
            )
            .toList()
          ..sort((a, b) {
            final aArabic =
                (a['id'] ?? '').startsWith('ara-') ||
                (a['id'] ?? '').startsWith('qurancom-');
            final bArabic =
                (b['id'] ?? '').startsWith('ara-') ||
                (b['id'] ?? '').startsWith('qurancom-');
            if (aArabic != bArabic) return aArabic ? -1 : 1;
            return (a['name'] ?? '').compareTo(b['name'] ?? '');
          });

    if (sources.isEmpty) {
      if (englishOnly) {
        return <Map<String, String>>[
          <String, String>{
            'id': 'eng-ummmuhammad',
            'name': 'Saheeh International',
          },
        ];
      }
      return <Map<String, String>>[
        <String, String>{'id': 'ara-jalaladdinalmah', 'name': 'تفسير الجلالين'},
      ];
    }

    return sources;
  }

  Future<String> getVerseMeanings(int surah, int ayah) async {
    return _getFawazVerseText(
      surah: surah,
      ayah: ayah,
      editions: const <String>['ara-jalaladdinalmah', 'eng-ummmuhammad'],
    );
  }

  Future<String> getVerseAsbab(int surah, int ayah) async {
    return '';
  }

  Future<Map<String, String>> getSurahInformation(int surah) async {
    try {
      final infoData = await _safeGetData(
        '$_fawazQuranBaseUrl/info.min.json',
        ttl: const Duration(hours: 12),
      );
      return _extractFawazSurahOverview(infoData, surah);
    } catch (e) {
      debugPrint('QuranApiService Surah Info (fawaz) Error: $e');
      return const {};
    }
  }

  Future<Map<String, dynamic>> getUnifiedSurahProfile(
    int surah, {
    int ayahForAsbab = 1,
    bool forceRefresh = false,
  }) async {
    final overview = await getSurahInformation(surah);
    final tafsirText = await getVerseTafsir(surah, ayahForAsbab);
    final translationText = await getVerseTranslation(
      surah,
      ayahForAsbab,
      languageCode: 'en',
    );

    return <String, dynamic>{
      'overview': overview,
      'tafsirs': <Map<String, dynamic>>[
        {'name': 'Tafsir from fawaz Quran API', 'content': tafsirText},
      ],
      'books': const <Map<String, dynamic>>[],
      'fatwas': const <Map<String, dynamic>>[],
      'tafsirSegments': const <Map<String, dynamic>>[],
      'asbabAyah': ayahForAsbab,
      'asbabText': '',
      'translationSample': translationText,
    };
  }

  Future<List<Map<String, dynamic>>> getAyahThemes(int surah, int ayah) async {
    return _getAsMapList(
      '$_quraniGeneralBaseUrl/ayah-theme/$surah/$ayah',
      ttl: const Duration(hours: 6),
    );
  }

  Future<List<Map<String, dynamic>>> getSimilarAyah(int surah, int ayah) async {
    return _getAsMapList(
      '$_quraniGeneralBaseUrl/similar-ayah/$surah/$ayah',
      ttl: const Duration(hours: 6),
    );
  }

  Future<List<Map<String, dynamic>>> getMutashabihat(
    int surah,
    int ayah,
  ) async {
    return _getAsMapList(
      '$_quraniGeneralBaseUrl/mutashabihat/$surah/$ayah',
      ttl: const Duration(hours: 6),
    );
  }

  Future<Map<String, dynamic>> getMorphologyWord(
    String wordReference, {
    bool forceRefresh = false,
  }) async {
    try {
      final data = await _safeGetData(
        '$_quraniGeneralBaseUrl/morphology/word/$wordReference',
        ttl: const Duration(days: 1),
        forceRefresh: forceRefresh,
      );
      return _asMap(data);
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, dynamic>> getWordTajweed({
    required int surah,
    required int ayah,
    required int word,
    bool forceRefresh = false,
  }) async {
    try {
      final data = await _safeGetData(
        '$_quraniGeneralBaseUrl/word/tajweed',
        queryParameters: {'surah': surah, 'ayah': ayah, 'word': word},
        ttl: const Duration(days: 1),
        forceRefresh: forceRefresh,
      );
      return _asMap(data);
    } catch (_) {
      return const {};
    }
  }

  Future<Map<String, dynamic>> getWordLineNumber({
    required int surah,
    required int ayah,
    required int word,
    bool forceRefresh = false,
  }) async {
    try {
      final data = await _safeGetData(
        '$_quraniGeneralBaseUrl/word/line-number',
        queryParameters: {'surah': surah, 'ayah': ayah, 'word': word},
        ttl: const Duration(days: 1),
        forceRefresh: forceRefresh,
      );
      return _asMap(data);
    } catch (_) {
      return const {};
    }
  }

  Future<List<Map<String, dynamic>>> searchGeneralQuran(
    String keyword, {
    String? language,
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    return _getAsMapList(
      '$_quraniGeneralBaseUrl/search/$keyword',
      queryParameters: {'language': language, 'limit': limit, 'offset': offset},
      ttl: const Duration(minutes: 15),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> searchQuranpedia(
    String query,
    String type, {
    bool forceRefresh = false,
  }) async {
    return _getAsMapList(
      '$_quranpediaBaseUrl/search/$query/$type',
      ttl: const Duration(minutes: 20),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> getEditions({
    String? language,
    String? type,
    String? format,
    bool forceRefresh = false,
  }) async {
    return _getAsMapList(
      '$_quraniGeneralBaseUrl/edition/',
      queryParameters: {'language': language, 'type': type, 'format': format},
      ttl: const Duration(days: 1),
      forceRefresh: forceRefresh,
    );
  }

  Future<List<Map<String, dynamic>>> getNarrationsDifferences({
    bool forceRefresh = false,
  }) async {
    return _getAsMapList(
      '$_quraniGeneralBaseUrl/narrations-differences/',
      ttl: const Duration(days: 1),
      forceRefresh: forceRefresh,
    );
  }

  Future<Map<String, dynamic>> getPageByNumber(
    int page, {
    String? editionIdentifier,
    bool forceRefresh = false,
  }) async {
    final url = editionIdentifier == null
        ? '$_quraniGeneralBaseUrl/page/$page'
        : '$_quraniGeneralBaseUrl/page/$page/$editionIdentifier';
    try {
      final data = await _safeGetData(
        url,
        ttl: const Duration(hours: 8),
        forceRefresh: forceRefresh,
      );
      return _asMap(data);
    } catch (_) {
      return const {};
    }
  }

  Future<String> _getFawazVerseText({
    required int surah,
    required int ayah,
    required List<String> editions,
  }) async {
    for (final edition in editions) {
      try {
        final data = await _safeGetData(
          '$_fawazQuranBaseUrl/editions/$edition/$surah/$ayah.min.json',
          ttl: const Duration(hours: 8),
        );
        final map = _asMap(data);
        final text = _cleanText(map['text']?.toString());
        if (text.isNotEmpty) return text;
      } catch (_) {
        continue;
      }
    }
    return '';
  }

  Future<String> _getOfflineTranslationText({
    required int surah,
    required int ayah,
    required bool isArabic,
  }) async {
    final assetPath = isArabic
        ? _offlineArabicTranslationAsset
        : _offlineEnglishTranslationAsset;
    return _getBundledVerseText(assetPath: assetPath, surah: surah, ayah: ayah);
  }

  Future<String> _getBundledOfflineTafsir({
    required String sourceId,
    required int surah,
    required int ayah,
  }) async {
    final assetPath = _resolveBundledTafsirAsset(sourceId);
    if (assetPath == null || assetPath.isEmpty) return '';
    return _getBundledVerseText(assetPath: assetPath, surah: surah, ayah: ayah);
  }

  String? _resolveBundledTafsirAsset(String sourceId) {
    final normalized = sourceId.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    return _offlineTafsirAssetBySource[normalized];
  }

  Future<String> _getBundledVerseText({
    required String assetPath,
    required int surah,
    required int ayah,
  }) async {
    final verses = await _loadBundledVerseMap(assetPath);
    return verses['$surah:$ayah'] ?? '';
  }

  Future<Map<String, String>> _loadBundledVerseMap(String assetPath) async {
    final cached = _offlineVerseTextCache[assetPath];
    if (cached != null) return cached;

    final loader = _offlineVerseTextLoaders.putIfAbsent(assetPath, () async {
      try {
        final rawJson = await rootBundle.loadString(assetPath);
        final decoded = json.decode(rawJson);
        final verses = _extractBundledVersesMap(decoded);
        _offlineVerseTextCache[assetPath] = verses;
        return verses;
      } catch (e) {
        debugPrint(
          'QuranApiService: failed to load bundled asset $assetPath: $e',
        );
        return const <String, String>{};
      }
    });

    return loader;
  }

  Map<String, String> _extractBundledVersesMap(dynamic raw) {
    final root = _asMap(raw);
    final data = _asMap(root['data']);
    final surahs = data['surahs'];
    if (surahs is! List) return const <String, String>{};

    final verses = <String, String>{};
    for (final surahEntry in surahs) {
      if (surahEntry is! Map) continue;
      final surahMap = surahEntry.cast<String, dynamic>();
      final surahNumber = _parseInt(surahMap['number']);
      if (surahNumber == null) continue;

      final ayahs = surahMap['ayahs'];
      if (ayahs is! List) continue;

      for (final ayahEntry in ayahs) {
        if (ayahEntry is! Map) continue;
        final ayahMap = ayahEntry.cast<String, dynamic>();
        final ayahNumber =
            _parseInt(ayahMap['numberInSurah']) ?? _parseInt(ayahMap['number']);
        if (ayahNumber == null) continue;

        final text = _cleanText(ayahMap['text']?.toString());
        if (text.isEmpty) continue;
        verses['$surahNumber:$ayahNumber'] = text;
      }
    }

    return verses;
  }

  Map<String, String> _extractFawazSurahOverview(dynamic raw, int surah) {
    final map = _asMap(raw);
    final chapters = map['chapters'];
    if (chapters is! List) return const {};

    Map<String, dynamic> chapter = const {};
    for (final item in chapters) {
      if (item is! Map) continue;
      final chapterNo = _parseInt(item['chapter']);
      if (chapterNo == surah) {
        chapter = item.cast<String, dynamic>();
        break;
      }
    }
    if (chapter.isEmpty) return const {};

    final verses = chapter['verses'];
    int verseCount = 0;
    int? firstPage;
    int? lastPage;
    int? firstJuz;
    int? firstRuku;
    if (verses is List && verses.isNotEmpty) {
      verseCount = verses.length;
      final first = verses.first;
      final last = verses.last;
      if (first is Map) {
        firstPage = _parseInt(first['page']);
        firstJuz = _parseInt(first['juz']);
        firstRuku = _parseInt(first['ruku']);
      }
      if (last is Map) {
        lastPage = _parseInt(last['page']);
      }
    }

    final revelationRaw = _cleanText(chapter['revelation']?.toString());
    final revelationNormalized = revelationRaw.toLowerCase();
    String revelation = revelationRaw;
    if (revelationNormalized.contains('mecca')) {
      revelation = 'مكية';
    } else if (revelationNormalized.contains('madina')) {
      revelation = 'مدنية';
    }

    final info = <String, String>{
      'Source': 'fawazahmed0/quran-api',
      'Surah Number': '$surah',
    };

    final name = _cleanText(chapter['name']?.toString());
    final english = _cleanText(chapter['englishname']?.toString());
    final arabic = _cleanText(chapter['arabicname']?.toString());
    if (name.isNotEmpty) info['Surah Name'] = name;
    if (english.isNotEmpty) info['English Name'] = english;
    if (arabic.isNotEmpty) info['Arabic Name (API)'] = arabic;
    if (revelation.isNotEmpty) info['Revelation'] = revelation;
    if (verseCount > 0) info['Ayah Count'] = '$verseCount';
    if (firstPage != null) info['First Page'] = '$firstPage';
    if (lastPage != null) info['Last Page'] = '$lastPage';
    if (firstJuz != null) info['First Juz'] = '$firstJuz';
    if (firstRuku != null) info['First Ruku'] = '$firstRuku';

    return info;
  }

  Future<List<Map<String, dynamic>>> _getAsMapList(
    String url, {
    Map<String, dynamic>? queryParameters,
    Duration? ttl,
    bool forceRefresh = false,
  }) async {
    try {
      final data = await _safeGetData(
        url,
        queryParameters: queryParameters,
        ttl: ttl,
        forceRefresh: forceRefresh,
      );
      return _asList(data);
    } catch (_) {
      return const [];
    }
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    if (data is Map) {
      for (final key in const ['data', 'result', 'items']) {
        final maybeList = data[key];
        if (maybeList is List) {
          return maybeList
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList();
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    if (data is List && data.isNotEmpty && data.first is Map) {
      return (data.first as Map).cast<String, dynamic>();
    }
    return const {};
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String _cleanText(String? input) {
    if (input == null || input.isEmpty) return '';
    var value = input;
    value = value.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    value = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
    value = value
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'");
    value = value.replaceAll(RegExp(r'[ \t]+'), ' ');
    value = value.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return value.trim();
  }

  bool _looksLikeTafsirEdition({
    required String id,
    required String author,
    required String language,
    required String source,
  }) {
    final normalized = '$id $author $language $source'.toLowerCase();
    for (final keyword in _tafsirDetectionKeywords) {
      if (normalized.contains(keyword)) return true;
    }
    return false;
  }

  bool _isLatinEditionVariant(String id) {
    final normalized = id.toLowerCase();
    return normalized.endsWith('-la') || normalized.endsWith('-lad');
  }

  bool _isArabicEdition(String id, String language) {
    final lang = language.toLowerCase();
    return id.startsWith('ara-') ||
        id.startsWith('qurancom-') ||
        lang == 'arabic' ||
        lang == 'ar';
  }

  bool _isEnglishEdition(String id, String language) {
    final lang = language.toLowerCase();
    return id.startsWith('eng-') || lang == 'english' || lang == 'en';
  }

  bool _containsArabicLetters(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  String _humanizeEditionName(String id, {String? language}) {
    final normalized = id.replaceAll('_', '-');
    final parts = normalized.split('-');
    final rawName = parts.length > 1 ? parts.sublist(1).join(' ') : normalized;
    final cleanedName = rawName.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanedName.isEmpty) return id;
    final title =
        cleanedName[0].toUpperCase() +
        (cleanedName.length > 1 ? cleanedName.substring(1) : '');
    final lang = (language ?? '').trim();
    return lang.isEmpty ? title : '$title ($lang)';
  }
}

class _ApiCacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  const _ApiCacheEntry({required this.data, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
