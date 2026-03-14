import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:islam_home/data/services/notification_service.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  final NotificationService _notificationService = NotificationService();

  // Active downloads: URL -> CancelToken
  final Map<String, CancelToken> _activeDownloads = {};

  // Download Queue
  final List<DownloadRequest> _queue = [];
  static const int _maxConcurrentDownloads = 3;
  int _currentDownloads = 0;

  // Callback for progress updates
  Function(String id, double progress, DownloadStatus status)? onProgress;

  Future<void> init() async {
    // Ensure download directory exists
    await _getDownloadDirectory();
  }

  Future<String> _getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${directory.path}/downloads');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  Future<String> getFilePath(
    String reciterId,
    String moshafType,
    int surahNumber, {
    String type = 'quran',
  }) async {
    final dir = await _getDownloadDirectory();
    if (type == 'seerah') {
      return '$dir/seerah/$reciterId/$surahNumber.mp3';
    } else if (type == 'general') {
      // Need to sanitize moshafType/album name just in case
      final safeType = moshafType.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      return '$dir/general/$safeType/$reciterId/$surahNumber.mp3';
    } else if (type == 'tafsir') {
      return '$dir/tafsir/$reciterId/$surahNumber.mp3';
    }
    return '$dir/$reciterId/$moshafType/$surahNumber.mp3';
  }

  Future<bool> isFileDownloaded(
    String reciterId,
    String moshafType,
    int surahNumber, {
    String type = 'quran',
  }) async {
    final path = await getFilePath(
      reciterId,
      moshafType,
      surahNumber,
      type: type,
    );
    return File(path).exists();
  }

  void addToQueue({
    required String url,
    required String reciterId,
    required String reciterName,
    required String moshafType,
    required int surahNumber,
    required String title,
    required String id,
    String type = 'quran',
  }) {
    // check if already downloading
    if (_activeDownloads.containsKey(url)) return;

    // check if already in queue
    if (_queue.any((req) => req.url == url)) return;

    final request = DownloadRequest(
      url: url,
      reciterId: reciterId,
      reciterName: reciterName,
      moshafType: moshafType,
      surahNumber: surahNumber,
      title: title,
      id: id,
      type: type,
    );

    _queue.add(request);
    _processQueue();
  }

  void _processQueue() {
    if (_currentDownloads >= _maxConcurrentDownloads || _queue.isEmpty) return;

    final request = _queue.removeAt(0);
    _startDownload(request);
  }

  Future<void> _startDownload(DownloadRequest request) async {
    _currentDownloads++;
    final cancelToken = CancelToken();
    _activeDownloads[request.url] = cancelToken;

    try {
      final filePath = await getFilePath(
        request.reciterId,
        request.moshafType,
        request.surahNumber,
        type: request.type,
      );

      // Ensure directory exists for this specific file
      final file = File(filePath);
      await file.parent.create(recursive: true);

      // Notify start
      _notifyProgress(request.id, 0.0, DownloadStatus.downloading);
      try {
        await _notificationService.showProgressNotification(
          id: request.notificationId,
          title: 'جاري تحميل ${request.title}',
          body: 'يرجى الانتظار...',
          progress: 0,
          maxProgress: 100,
        );
      } catch (e) {
        debugPrint('Notification error on start: $e');
      }

      await _dio.download(
        request.url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            _notifyProgress(request.id, progress, DownloadStatus.downloading);

            // Throttle notification updates. Update every 5%, but skip exactly 100%
            // as showDownloadCompleteNotification will handle the final state.
            final progressInt = (progress * 100).toInt();
            if (progressInt % 5 == 0 && progressInt < 100) {
              try {
                _notificationService.showProgressNotification(
                  id: request.notificationId,
                  title: 'جاري تحميل ${request.title}',
                  body: '$progressInt%',
                  progress: progressInt,
                  maxProgress: 100,
                );
              } catch (e) {
                // Ignore periodic notification errors
              }
            }
          }
        },
      );

      // Notify complete
      _notifyProgress(request.id, 1.0, DownloadStatus.completed);
      await _addToHistory(request);
      
      // Small delay to ensure the OS has handled any pending progress updates
      await Future.delayed(const Duration(milliseconds: 200));
      
      try {
        await _notificationService.showDownloadCompleteNotification(
          id: request.notificationId,
          title: 'تم التحميل',
          body: 'تم تحميل ${request.title} بنجاح',
        );
      } catch (e) {
        debugPrint('Notification error on complete: $e');
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        debugPrint('Download canceled: ${request.url}');
        _notifyProgress(request.id, 0.0, DownloadStatus.canceled);
      } else {
        debugPrint('Download error: $e');
        _notifyProgress(request.id, 0.0, DownloadStatus.failed);
        try {
          await _notificationService.showDownloadCompleteNotification(
            id: request.notificationId,
            title: 'فشل التحميل',
            body: 'حدث خطأ أثناء تحميل ${request.title}',
          );
        } catch (ne) {
          debugPrint('Notification error on throw: $ne');
        }
      }
    } finally {
      _activeDownloads.remove(request.url);
      _currentDownloads--;
      _processQueue(); // Start next in queue
    }
  }

  void cancelDownload(String url) {
    if (_activeDownloads.containsKey(url)) {
      _activeDownloads[url]?.cancel();
      _activeDownloads.remove(url);
    } else {
      // Remove from queue if not started yet
      _queue.removeWhere((req) => req.url == url);
    }
  }

  Future<void> deleteDownload(
    String reciterId,
    String moshafType,
    int surahNumber,
  ) async {
    final path = await getFilePath(reciterId, moshafType, surahNumber);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Metadata Persistence
  List<DownloadRequest> _downloadedHistory = [];

  Future<List<DownloadRequest>> getDownloadedHistory() async {
    if (_downloadedHistory.isEmpty) {
      await _loadHistory();
    }
    return _downloadedHistory;
  }

  Future<void> _loadHistory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/downloads_history.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(
          jsonString,
        ); // Needs dart:convert
        _downloadedHistory = jsonList
            .map((j) => DownloadRequest.fromJson(j))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _addToHistory(DownloadRequest request) async {
    // Avoid duplicates
    _downloadedHistory.removeWhere((item) => item.id == request.id);
    _downloadedHistory.add(request);
    await _saveHistory();
  }

  Future<void> removeFromHistory(String id) async {
    _downloadedHistory.removeWhere((item) => item.id == id);
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/downloads_history.json');
      final jsonList = _downloadedHistory.map((item) => item.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  void _notifyProgress(String id, double progress, DownloadStatus status) {
    if (onProgress != null) {
      onProgress!(id, progress, status);
    }
  }
}

class DownloadRequest {
  final String url;
  final String reciterId;
  final String reciterName;
  final String moshafType;
  final int surahNumber;
  final String title;
  final String id;
  final String type; // 'quran' or 'seerah'
  final int notificationId;

  DownloadRequest({
    required this.url,
    required this.reciterId,
    required this.reciterName,
    required this.moshafType,
    required this.surahNumber,
    required this.title,
    required this.id,
    this.type = 'quran',
    int? notificationId,
  }) : notificationId = notificationId ?? id.hashCode.abs();

  Map<String, dynamic> toJson() => {
    'url': url,
    'reciterId': reciterId,
    'reciterName': reciterName,
    'moshafType': moshafType,
    'surahNumber': surahNumber,
    'title': title,
    'id': id,
    'type': type,
    'notificationId': notificationId,
  };

  factory DownloadRequest.fromJson(Map<String, dynamic> json) =>
      DownloadRequest(
        url: json['url'],
        reciterId: json['reciterId'],
        reciterName: json['reciterName'] ?? json['reciterId'],
        moshafType: json['moshafType'],
        surahNumber: json['surahNumber'],
        title: json['title'],
        id: json['id'],
        type: json['type'] ?? 'quran',
        notificationId: json['notificationId'],
      );
}

enum DownloadStatus { idle, downloading, completed, failed, canceled }
