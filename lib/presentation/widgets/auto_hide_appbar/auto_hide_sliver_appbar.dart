import 'package:flutter/material.dart';
import 'auto_hide_appbar_behavior.dart';
import 'auto_hide_appbar_config.dart';

/// A wrapper widget that combines SliverAppBar with auto-hide behavior.
///
/// This widget automatically hides the AppBar when the user scrolls down
/// and shows it again when scrolling up, providing a better reading experience
/// by maximizing screen space.
///
/// The widget uses [AutoHideAppBarBehavior] to detect scroll events and
/// an [AnimationController] to smoothly animate the AppBar visibility.
class AutoHideSliverAppBar extends StatefulWidget {
  /// The primary widget displayed in the app bar.
  final Widget title;

  /// A list of Widgets to display in a row after the title widget.
  final List<Widget>? actions;

  /// A widget to display before the title.
  final Widget? leading;

  /// The size of the app bar when it is fully expanded.
  final double expandedHeight;

  /// This widget is stacked behind the toolbar and the tab bar.
  final Widget? flexibleSpace;

  /// The color to use for the app bar's material.
  final Color? backgroundColor;

  /// The scroll controller that monitors scroll events.
  final ScrollController scrollController;

  /// Configuration for customizing auto-hide behavior.
  final AutoHideAppBarConfig? config;

  /// Creates an [AutoHideSliverAppBar].
  ///
  /// The [title] and [scrollController] parameters are required.
  const AutoHideSliverAppBar({
    super.key,
    required this.title,
    required this.scrollController,
    this.actions,
    this.leading,
    this.expandedHeight = 120.0,
    this.flexibleSpace,
    this.backgroundColor,
    this.config,
  });

  @override
  State<AutoHideSliverAppBar> createState() => _AutoHideSliverAppBarState();
}

class _AutoHideSliverAppBarState extends State<AutoHideSliverAppBar>
    with SingleTickerProviderStateMixin {
  late AutoHideAppBarBehavior _behavior;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ValueNotifier<bool> _isVisible;

  @override
  void initState() {
    super.initState();

    // Get config or use default
    final config = widget.config ?? const AutoHideAppBarConfig();

    // Initialize animation controller with 250ms duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    // Create curved animation with easeInOutCubic curve
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Initialize visibility notifier
    _isVisible = ValueNotifier<bool>(true);

    // Create and initialize AutoHideAppBarBehavior
    _behavior = AutoHideAppBarBehavior(
      scrollController: widget.scrollController,
      isAppBarVisible: _isVisible,
      config: config,
    );

    // Connect visibility notifier to animation controller
    _isVisible.addListener(_onVisibilityChanged);

    // Initialize behavior
    _behavior.initialize();

    // Start with AppBar visible
    _animationController.forward();
  }

  @override
  void dispose() {
    _isVisible.removeListener(_onVisibilityChanged);
    _behavior.dispose();
    _animationController.dispose();
    _isVisible.dispose();
    super.dispose();
  }

  /// Handles visibility changes by triggering appropriate animations.
  void _onVisibilityChanged() {
    if (_isVisible.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SliverAppBar(
          expandedHeight: widget.expandedHeight * _animation.value,
          pinned: false,
          floating: true,
          snap: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: widget.backgroundColor,
          centerTitle: true,
          leading: widget.leading,
          actions: widget.actions,
          flexibleSpace: widget.flexibleSpace,
          title: Opacity(opacity: _animation.value, child: widget.title),
        );
      },
    );
  }
}
