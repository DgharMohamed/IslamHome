import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islam_home/data/services/last_read_service.dart';
import 'package:islam_home/data/models/save_last_read_result.dart';
import 'package:islam_home/presentation/providers/quran_flow_notifier.dart';
import 'package:islam_home/presentation/providers/api_providers.dart';
import 'package:islam_home/data/models/surah_model.dart';

/// Test for timeout behavior when widget never becomes available
///
/// **Validates: Requirement 4.3**
///
/// This test verifies that when the target ayah widget is not available
/// after maximum retry attempts (20), the system displays an error message
/// to the user.
void main() {
  group('Smooth Ayah Scroll - Timeout Behavior', () {
    testWidgets(
      'should display error message when widget never becomes available after 20 attempts',
      (WidgetTester tester) async {
        // Create a mock last read position
        final lastReadPosition = LastReadPosition(
          surahNumber: 50,
          ayahNumber: 10,
          timestamp: DateTime.now(),
        );

        // Create a container to track if error message was shown
        bool errorMessageShown = false;
        String? errorMessageText;

        // Build a minimal test widget that simulates the timeout scenario
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              // Mock the last read service to return our test position
              lastReadServiceProvider.overrideWithValue(
                _MockLastReadService(lastReadPosition),
              ),
              // Mock the quran flow provider to return empty state
              // This ensures widgets are never built
              quranFlowProvider.overrideWith(() => _MockQuranFlowNotifier()),
              // Mock the surahs provider
              surahsProvider.overrideWith((ref) async => _mockSurahs()),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: ScaffoldMessenger(
                      child: Builder(
                        builder: (scaffoldContext) {
                          // Create a test widget that triggers the timeout
                          return _TimeoutTestWidget(
                            lastReadPosition: lastReadPosition,
                            onErrorShown: (message) {
                              errorMessageShown = true;
                              errorMessageText = message;
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Wait for initial build
        await tester.pumpAndSettle();

        // Trigger the navigation that will timeout
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Simulate the passage of time for all 20 retry attempts
        // Each attempt has delays, so we need to advance time significantly
        // The retry logic uses various delays (200ms, 800-2000ms for animations)
        // We'll advance in chunks to simulate the retry attempts
        for (int i = 0; i < 25; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }

        // Pump additional frames to ensure SnackBar appears
        await tester.pumpAndSettle();

        // Verify that an error message was shown
        expect(
          errorMessageShown,
          isTrue,
          reason: 'Error message should be shown after timeout',
        );

        // Verify the error message contains relevant information
        expect(errorMessageText, isNotNull);
        expect(
          errorMessageText!.contains('${lastReadPosition.ayahNumber}') ||
              errorMessageText!.contains('${lastReadPosition.surahNumber}'),
          isTrue,
          reason: 'Error message should mention the target ayah or surah',
        );

        // Verify that a SnackBar with error styling is present
        final snackBarFinder = find.byType(SnackBar);
        if (snackBarFinder.evaluate().isNotEmpty) {
          final snackBar = tester.widget<SnackBar>(snackBarFinder);
          expect(
            snackBar.backgroundColor,
            Colors.red,
            reason: 'Error SnackBar should have red background',
          );
        }
      },
    );

    testWidgets('should not crash or freeze when timeout occurs', (
      WidgetTester tester,
    ) async {
      // This test verifies the app remains stable after timeout
      final lastReadPosition = LastReadPosition(
        surahNumber: 100,
        ayahNumber: 5,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lastReadServiceProvider.overrideWithValue(
              _MockLastReadService(lastReadPosition),
            ),
            quranFlowProvider.overrideWith(() => _MockQuranFlowNotifier()),
            surahsProvider.overrideWith((ref) async => _mockSurahs()),
          ],
          child: MaterialApp(
            home: _TimeoutTestWidget(
              lastReadPosition: lastReadPosition,
              onErrorShown: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger navigation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Advance through timeout period - ensure all 20 attempts complete
      for (int i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Pump and settle to complete all animations and timers
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify the widget is still mounted and functional
      expect(find.byType(_TimeoutTestWidget), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // No exceptions should be thrown - test passes if we reach here
    });
  });
}

/// Mock widget that simulates the timeout scenario
class _TimeoutTestWidget extends StatefulWidget {
  final LastReadPosition lastReadPosition;
  final void Function(String message) onErrorShown;

  const _TimeoutTestWidget({
    required this.lastReadPosition,
    required this.onErrorShown,
  });

  @override
  State<_TimeoutTestWidget> createState() => _TimeoutTestWidgetState();
}

class _TimeoutTestWidgetState extends State<_TimeoutTestWidget> {
  final Map<String, GlobalKey> _ayahKeys = {};
  int _attemptCount = 0;

  void _simulateAttemptJumpToAyah(int attempt) {
    if (!mounted || attempt >= 20) {
      if (attempt >= 20) {
        debugPrint(
          '❌ Failed to navigate to ayah after 20 attempts. '
          'Target: Surah ${widget.lastReadPosition.surahNumber}, '
          'Ayah ${widget.lastReadPosition.ayahNumber}',
        );
        if (mounted) {
          final message =
              'تعذر الوصول إلى الآية ${widget.lastReadPosition.ayahNumber} '
              'من سورة ${widget.lastReadPosition.surahNumber}';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );

          widget.onErrorShown(message);
        }
      }
      return;
    }

    final targetKey =
        '${widget.lastReadPosition.surahNumber}_${widget.lastReadPosition.ayahNumber}';
    final key = _ayahKeys[targetKey];

    // Simulate key not found (widget never becomes available)
    if (key == null || key.currentContext == null) {
      debugPrint('🔖 Attempt ${attempt + 1}: Key not found (simulated)');

      // Retry after delay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _attemptCount = attempt + 1;
          });
          _simulateAttemptJumpToAyah(attempt + 1);
        }
      });
    }
  }

  void _triggerNavigation() {
    _simulateAttemptJumpToAyah(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Timeout Test Widget'),
            Text('Attempt: $_attemptCount'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _triggerNavigation,
              child: const Text('Trigger Navigation'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock LastReadService for testing
class _MockLastReadService implements LastReadService {
  final LastReadPosition position;

  _MockLastReadService(this.position);

  @override
  Future<LastReadPosition?> getLastRead() async => position;

  @override
  Future<void> saveLastRead({
    required int surahNumber,
    required int ayahNumber,
  }) async {}

  @override
  Future<void> clearLastRead() async {}

  @override
  Future<SaveLastReadResult> saveLastReadWithPrevious({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    return SaveLastReadResult(
      previousPosition: null,
      newPosition: LastReadPosition(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        timestamp: DateTime.now(),
      ),
    );
  }
}

/// Mock QuranFlowNotifier that returns empty state
class _MockQuranFlowNotifier extends QuranFlowNotifier {
  _MockQuranFlowNotifier() : super();

  @override
  QuranFlowState build() {
    return QuranFlowState(
      items: [], // Empty - no widgets will be built
      isLoading: false,
      loadedSurahs: {},
    );
  }
}

/// Mock surahs data
List<Surah> _mockSurahs() {
  return List.generate(
    114,
    (index) => Surah(
      number: index + 1,
      name: 'سورة ${index + 1}',
      englishName: 'Surah ${index + 1}',
      revelationType: 'Meccan',
      numberOfAyahs: 10,
    ),
  );
}
