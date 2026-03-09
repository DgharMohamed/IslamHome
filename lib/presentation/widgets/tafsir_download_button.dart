import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/models/tafsir_model.dart';
import 'package:islam_home/data/services/download_service.dart';
import 'package:islam_home/presentation/providers/download_state.dart';

class TafsirDownloadButton extends ConsumerStatefulWidget {
  final String tafsirName;
  final TafsirSurah surahPart;
  final Color? color;

  const TafsirDownloadButton({
    super.key,
    required this.tafsirName,
    required this.surahPart,
    this.color,
  });

  @override
  ConsumerState<TafsirDownloadButton> createState() =>
      _TafsirDownloadButtonState();
}

class _TafsirDownloadButtonState extends ConsumerState<TafsirDownloadButton> {
  bool _isDownloaded = false;
  bool _isLoadingCheck = true;
  String get _id =>
      'tafsir_${widget.tafsirName}_tafsir_audio_${widget.surahPart.id}';

  @override
  void initState() {
    super.initState();
    _checkFileStatus();
  }

  Future<void> _checkFileStatus() async {
    final notifier = ref.read(downloadProvider.notifier);
    final exists = await notifier.isTafsirDownloaded(
      widget.tafsirName,
      widget.surahPart.id,
    );
    if (mounted) {
      setState(() {
        _isDownloaded = exists;
        _isLoadingCheck = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadProvider);
    final itemState = downloadState[_id];

    if (itemState != null) {
      switch (itemState.status) {
        case DownloadStatus.idle:
        case DownloadStatus.downloading:
          return SizedBox(
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: itemState.progress > 0 ? itemState.progress : null,
                  strokeWidth: 2,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
                Icon(
                  Icons.close,
                  size: 14,
                  color: widget.color ?? Theme.of(context).primaryColor,
                ),
              ],
            ),
          );
        case DownloadStatus.completed:
          return Icon(
            Icons.check_circle,
            color: widget.color ?? Theme.of(context).primaryColor,
          );
        case DownloadStatus.failed:
          return IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.red),
            onPressed: () => _startDownload(),
          );
        case DownloadStatus.canceled:
          break;
      }
    }

    if (_isLoadingCheck) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_isDownloaded) {
      return Icon(
        Icons.check_circle_outline,
        color: widget.color ?? Theme.of(context).primaryColor,
      );
    }

    return IconButton(
      icon: Icon(
        Icons.download_rounded,
        color: widget.color ?? Theme.of(context).primaryColor,
      ),
      onPressed: _startDownload,
    );
  }

  void _startDownload() {
    ref
        .read(downloadProvider.notifier)
        .startTafsirDownload(
          tafsirName: widget.tafsirName,
          title: widget.surahPart.name,
          url: widget.surahPart.url,
          surahId: widget.surahPart.id,
        );
  }
}
