import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:islam_home/data/models/mushaf_riwaya.dart';

// ─── Selected Riwaya Provider ─────────────────────────────────────────────────

final selectedRiwayaProvider =
    NotifierProvider<SelectedRiwayaNotifier, MushafRiwaya>(
      SelectedRiwayaNotifier.new,
    );

class SelectedRiwayaNotifier extends Notifier<MushafRiwaya> {
  static const _key = 'selected_riwaya';
  late Box _box;

  @override
  MushafRiwaya build() {
    _box = Hive.box('settings');
    final key = _box.get(_key, defaultValue: 'hafs') as String;
    return MushafRiwaya.fromKey(key);
  }

  void selectRiwaya(MushafRiwaya riwaya) {
    state = riwaya;
    _box.put(_key, riwaya.key);
  }
}

// ─── Download State ───────────────────────────────────────────────────────────

enum RiwayaDownloadStatus { notDownloaded, downloading, downloaded, error }

class RiwayaDownloadState {
  final RiwayaDownloadStatus status;
  final double progress; // 0.0 – 1.0
  final String? errorMessage;

  const RiwayaDownloadState({
    required this.status,
    this.progress = 0,
    this.errorMessage,
  });

  bool get isDownloaded => status == RiwayaDownloadStatus.downloaded;
  bool get isDownloading => status == RiwayaDownloadStatus.downloading;
}

// ─── Download Provider ────────────────────────────────────────────────────────

final riwayaDownloadManagerProvider =
    NotifierProvider<RiwayaDownloadManager, Map<String, RiwayaDownloadState>>(
      RiwayaDownloadManager.new,
    );

class RiwayaDownloadManager extends Notifier<Map<String, RiwayaDownloadState>> {
  final _dio = Dio();

  @override
  Map<String, RiwayaDownloadState> build() {
    // Check which fonts are already downloaded on init
    _initDownloadedFonts();
    return {};
  }

  Future<void> _initDownloadedFonts() async {
    final dir = await getApplicationDocumentsDirectory();
    final updates = <String, RiwayaDownloadState>{};
    for (final riwaya in MushafRiwaya.all) {
      if (!riwaya.isOffline) {
        final file = File('${dir.path}/fonts/${riwaya.key}.otf');
        if (await file.exists()) {
          updates[riwaya.key] = const RiwayaDownloadState(
            status: RiwayaDownloadStatus.downloaded,
            progress: 1.0,
          );
          // Load the font into Flutter's font registry
          await _loadFontFromFile(riwaya, file);
        } else {
          updates[riwaya.key] = const RiwayaDownloadState(
            status: RiwayaDownloadStatus.notDownloaded,
          );
        }
      }
    }
    if (updates.isNotEmpty) {
      state = {...state, ...updates};
    }
  }

  bool isDownloaded(String key) {
    return state[key]?.isDownloaded ?? false;
  }

  double progress(String key) {
    return state[key]?.progress ?? 0;
  }

  Future<void> downloadRiwaya(MushafRiwaya riwaya) async {
    if (riwaya.isOffline || riwaya.fontUrl == null) return;
    if (state[riwaya.key]?.isDownloading ?? false) return;

    state = {
      ...state,
      riwaya.key: const RiwayaDownloadState(
        status: RiwayaDownloadStatus.downloading,
        progress: 0,
      ),
    };

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fontsDir = Directory('${dir.path}/fonts');
      if (!await fontsDir.exists()) {
        await fontsDir.create(recursive: true);
      }

      final filePath = '${fontsDir.path}/${riwaya.key}.otf';

      await _dio.download(
        riwaya.fontUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = {
              ...state,
              riwaya.key: RiwayaDownloadState(
                status: RiwayaDownloadStatus.downloading,
                progress: received / total,
              ),
            };
          }
        },
      );

      final file = File(filePath);
      await _loadFontFromFile(riwaya, file);

      state = {
        ...state,
        riwaya.key: const RiwayaDownloadState(
          status: RiwayaDownloadStatus.downloaded,
          progress: 1.0,
        ),
      };
    } catch (e) {
      state = {
        ...state,
        riwaya.key: RiwayaDownloadState(
          status: RiwayaDownloadStatus.error,
          errorMessage: e.toString(),
        ),
      };
    }
  }

  Future<void> _loadFontFromFile(MushafRiwaya riwaya, File file) async {
    final bytes = await file.readAsBytes();
    final fontLoader = FontLoader(riwaya.fontFamily);
    fontLoader.addFont(
      Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
    );
    await fontLoader.load();
  }
}
