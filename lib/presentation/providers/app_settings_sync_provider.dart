import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islam_home/data/services/auth_service.dart';
import 'package:islam_home/data/services/firestore_sync_service.dart';
import 'package:islam_home/presentation/providers/locale_provider.dart';
import 'package:islam_home/presentation/providers/mushaf_settings_provider.dart';

/// Provider responsible for bidirectional synchronization of application settings.
final appSettingsSyncProvider = Provider<AppSettingsSyncProvider>((ref) {
  final syncService = ref.watch(firestoreSyncServiceProvider);
  return AppSettingsSyncProvider(ref, syncService);
});

class AppSettingsSyncProvider {
  final Ref _ref;
  final FirestoreSyncService _syncService;
  bool _isSyncingFromCloud = false;

  AppSettingsSyncProvider(this._ref, this._syncService) {
    _init();
  }

  void _init() {
    // Listen to Auth state changes
    _ref.listen(authStateProvider, (previous, next) {
      final user = next.value;
      if (user != null && !user.isAnonymous) {
        // Fetch cloud settings when a real user logs in
        _fetchAndApplyCloudSettings();
      }
    });

    // Listen to local settings changes and push to cloud
    _ref.listen(localeProvider, (previous, next) {
      if (!_isSyncingFromCloud) {
        _pushSettingsToCloud();
      }
    });

    _ref.listen(mushafSettingsProvider, (previous, next) {
      if (!_isSyncingFromCloud) {
        _pushSettingsToCloud();
      }
    });
  }

  Future<void> _fetchAndApplyCloudSettings() async {
    _isSyncingFromCloud = true;
    try {
      final cloudSettings = await _syncService.getCloudSettings();
      if (cloudSettings != null) {
        debugPrint('AppSettingsSyncProvider: Applying cloud settings...');
        final box = Hive.box('settings');

        // 1. Language
        if (cloudSettings.containsKey('language')) {
          final lang = cloudSettings['language'] as String;
          await box.put('language', lang);
          // Manually update locale state if it differs
          final currentLocale = _ref.read(localeProvider);
          if (currentLocale.languageCode != lang) {
            _ref.read(localeProvider.notifier).setLocale(Locale(lang));
          }
        }

        // 2. Mushaf Font Size
        if (cloudSettings.containsKey('mushaf_font_size_scale')) {
          final scale = (cloudSettings['mushaf_font_size_scale'] as num)
              .toDouble();
          await box.put('mushaf_font_size_scale', scale);
          _ref.read(mushafSettingsProvider.notifier).setFontSizeScale(scale);
        }

        // Add more settings as needed
      }
    } catch (e) {
      debugPrint('AppSettingsSyncProvider: Error fetching cloud settings: $e');
    } finally {
      _isSyncingFromCloud = false;
    }
  }

  Future<void> _pushSettingsToCloud() async {
    final user = _ref.read(authStateProvider).value;
    if (user == null || user.isAnonymous) return;

    final box = Hive.box('settings');
    final settings = <String, dynamic>{};
    for (var key in box.keys) {
      settings[key.toString()] = box.get(key);
    }

    if (settings.isNotEmpty) {
      await _syncService.syncSettings(settings);
    }
  }
}
