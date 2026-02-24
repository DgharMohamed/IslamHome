class AyahTiming {
  final int surahNumber;
  final int ayahNumber;
  final int startTimeMs;

  AyahTiming({
    required this.surahNumber,
    required this.ayahNumber,
    required this.startTimeMs,
  });

  @override
  String toString() => 'AyahTiming($surahNumber:$ayahNumber, $startTimeMs ms)';
}
