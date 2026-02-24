import 'package:flutter/widgets.dart';
import 'auto_hide_appbar_config.dart';
import 'scroll_direction.dart' as custom;

/// Manages the auto-hide logic for an AppBar based on scroll events.
///
/// This class listens to a [ScrollController] and determines when to hide
/// or show the AppBar based on scroll direction and configured thresholds.
/// It uses a [ValueNotifier] to communicate visibility state changes.
class AutoHideAppBarBehavior {
  /// The scroll controller to monitor for scroll events.
  final ScrollController scrollController;

  /// Notifier that tracks whether the AppBar should be visible.
  final ValueNotifier<bool> isAppBarVisible;

  /// Configuration for auto-hide behavior.
  final AutoHideAppBarConfig config;

  /// The last recorded scroll offset.
  double _lastScrollOffset = 0.0;

  /// The last detected scroll direction.
  custom.ScrollDirection _lastDirection = custom.ScrollDirection.idle;

  /// The accumulated scroll distance in the current direction.
  double _accumulatedDelta = 0.0;

  /// Creates an [AutoHideAppBarBehavior] instance.
  ///
  /// Requires a [scrollController] to monitor and an [isAppBarVisible] notifier
  /// to update. Optionally accepts a [config] for customizing behavior.
  AutoHideAppBarBehavior({
    required this.scrollController,
    required this.isAppBarVisible,
    AutoHideAppBarConfig? config,
  }) : config = config ?? const AutoHideAppBarConfig();

  /// Initializes the behavior by attaching the scroll listener.
  ///
  /// This should be called during widget initialization (e.g., in initState).
  void initialize() {
    if (!config.enableAutoHide) {
      return;
    }

    _lastScrollOffset = scrollController.hasClients
        ? scrollController.offset
        : 0.0;
    scrollController.addListener(_onScroll);
  }

  /// Disposes the behavior by removing the scroll listener.
  ///
  /// This should be called during widget disposal (e.g., in dispose).
  void dispose() {
    scrollController.removeListener(_onScroll);
  }

  /// Resets the AppBar to visible state and clears scroll tracking.
  ///
  /// This is useful when navigating to a new screen or when the app resumes.
  void reset() {
    isAppBarVisible.value = true;
    _lastScrollOffset = scrollController.hasClients
        ? scrollController.offset
        : 0.0;
    _accumulatedDelta = 0.0;
    _lastDirection = custom.ScrollDirection.idle;
  }

  /// Handles scroll events and updates AppBar visibility accordingly.
  void _onScroll() {
    if (!config.enableAutoHide) {
      return;
    }

    // Ignore scroll events if controller is not attached
    if (!scrollController.hasClients) {
      return;
    }

    final currentOffset = scrollController.offset;

    // Clamp offset to valid range
    final clampedOffset = currentOffset.clamp(
      0.0,
      scrollController.position.maxScrollExtent,
    );

    // Always show AppBar at the top
    if (clampedOffset <= 0.0) {
      if (!isAppBarVisible.value) {
        isAppBarVisible.value = true;
      }
      _lastScrollOffset = clampedOffset;
      _accumulatedDelta = 0.0;
      _lastDirection = custom.ScrollDirection.idle;
      return;
    }

    final delta = clampedOffset - _lastScrollOffset;

    // Determine current scroll direction
    custom.ScrollDirection currentDirection;
    if (delta > 0) {
      currentDirection = custom.ScrollDirection.down;
    } else if (delta < 0) {
      currentDirection = custom.ScrollDirection.up;
    } else {
      currentDirection = custom.ScrollDirection.idle;
      return; // No movement, nothing to do
    }

    // Reset accumulated delta if direction changed
    if (currentDirection != _lastDirection &&
        _lastDirection != custom.ScrollDirection.idle) {
      _accumulatedDelta = 0.0;
    }

    // Accumulate delta in current direction
    _accumulatedDelta += delta.abs();

    // Check if threshold is exceeded and trigger visibility change
    if (currentDirection == custom.ScrollDirection.down) {
      // Scrolling down - hide AppBar
      if (_accumulatedDelta >= config.hideThreshold && isAppBarVisible.value) {
        isAppBarVisible.value = false;
        _accumulatedDelta = 0.0;
      }
    } else if (currentDirection == custom.ScrollDirection.up) {
      // Scrolling up - show AppBar
      if (_accumulatedDelta >= config.showThreshold && !isAppBarVisible.value) {
        isAppBarVisible.value = true;
        _accumulatedDelta = 0.0;
      }
    }

    _lastScrollOffset = clampedOffset;
    _lastDirection = currentDirection;
  }
}
