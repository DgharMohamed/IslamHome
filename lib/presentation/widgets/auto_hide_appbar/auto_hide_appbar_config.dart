import 'package:flutter/animation.dart';

/// Configuration class for customizing auto-hide AppBar behavior.
///
/// This class defines the thresholds, animation settings, and other parameters
/// that control how the AppBar automatically hides and shows during scrolling.
class AutoHideAppBarConfig {
  /// The minimum scroll distance (in pixels) required to trigger hiding the AppBar.
  final double hideThreshold;

  /// The minimum scroll distance (in pixels) required to trigger showing the AppBar.
  final double showThreshold;

  /// The duration of the hide/show animation.
  final Duration animationDuration;

  /// The curve used for the hide/show animation.
  final Curve animationCurve;

  /// Whether auto-hide behavior is enabled.
  final bool enableAutoHide;

  /// Creates an [AutoHideAppBarConfig] with the specified settings.
  ///
  /// Default values:
  /// - [hideThreshold]: 50.0 pixels
  /// - [showThreshold]: 20.0 pixels
  /// - [animationDuration]: 250 milliseconds
  /// - [animationCurve]: Curves.easeInOutCubic
  /// - [enableAutoHide]: true
  const AutoHideAppBarConfig({
    this.hideThreshold = 50.0,
    this.showThreshold = 20.0,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeInOutCubic,
    this.enableAutoHide = true,
  });

  /// Creates a copy of this configuration with the given fields replaced
  /// with new values.
  AutoHideAppBarConfig copyWith({
    double? hideThreshold,
    double? showThreshold,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enableAutoHide,
  }) {
    return AutoHideAppBarConfig(
      hideThreshold: hideThreshold ?? this.hideThreshold,
      showThreshold: showThreshold ?? this.showThreshold,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enableAutoHide: enableAutoHide ?? this.enableAutoHide,
    );
  }
}
