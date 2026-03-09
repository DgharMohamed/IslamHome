import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track if the AyahDedicatedPlayer is minimized (compact pill mode)
/// or expanded (full controls).
final audioPlayerMinimizedProvider =
    NotifierProvider<AudioPlayerMinimizedNotifier, bool>(
      AudioPlayerMinimizedNotifier.new,
    );

class AudioPlayerMinimizedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setMinimized(bool value) => state = value;
}
