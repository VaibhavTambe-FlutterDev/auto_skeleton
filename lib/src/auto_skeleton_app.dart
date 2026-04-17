import 'package:flutter/material.dart';
import 'smart_placeholder.dart';
import 'effects/placeholder_effect.dart';

/// App-level skeleton wrapper that automatically applies skeleton loading
/// to every screen in your app. No per-widget wrapping needed.
///
/// ## Usage
///
/// ```dart
/// MaterialApp(
///   builder: AutoSkeletonApp.builder(
///     loadingNotifier: isAppLoading, // ValueNotifier<bool>
///   ),
///   home: MyHomePage(),
/// )
/// ```
///
/// ## With NavigatorObserver (auto-detect route transitions)
///
/// ```dart
/// final skeletonController = AutoSkeletonAppController();
///
/// MaterialApp(
///   builder: AutoSkeletonApp.builder(
///     controller: skeletonController,
///   ),
///   navigatorObservers: [skeletonController.observer],
///   home: MyHomePage(),
/// )
/// ```
class AutoSkeletonApp {
  AutoSkeletonApp._();

  /// Returns a [TransitionBuilder] that wraps every route with [AutoSkeleton].
  ///
  /// Use this as the `builder` parameter of [MaterialApp]:
  ///
  /// ```dart
  /// MaterialApp(
  ///   builder: AutoSkeletonApp.builder(
  ///     loadingNotifier: myLoadingState,
  ///   ),
  ///   home: MyHomePage(),
  /// )
  /// ```
  ///
  /// [loadingNotifier] — a [ValueNotifier<bool>] that controls skeleton visibility.
  /// When `true`, the skeleton overlay is shown over the entire screen.
  ///
  /// [controller] — an [AutoSkeletonAppController] for programmatic control.
  /// Use either [loadingNotifier] or [controller], not both.
  ///
  /// [effect] — optional custom effect for the skeleton.
  ///
  /// [enableSwitchAnimation] — whether to animate skeleton → content transition.
  static TransitionBuilder builder({
    ValueNotifier<bool>? loadingNotifier,
    AutoSkeletonAppController? controller,
    PlaceholderEffect? effect,
    bool enableSwitchAnimation = true,
  }) {
    assert(
      loadingNotifier != null || controller != null,
      'Provide either loadingNotifier or controller.',
    );

    final notifier = loadingNotifier ?? controller!._loadingNotifier;

    return (context, child) {
      return _AutoSkeletonAppWidget(
        loadingNotifier: notifier,
        effect: effect,
        enableSwitchAnimation: enableSwitchAnimation,
        child: child ?? const SizedBox.shrink(),
      );
    };
  }
}

/// Controller for [AutoSkeletonApp] with programmatic loading control.
///
/// ```dart
/// final controller = AutoSkeletonAppController();
///
/// // Start loading
/// controller.startLoading();
///
/// // Stop loading (shows content with animation)
/// controller.stopLoading();
///
/// // Check state
/// print(controller.isLoading); // true/false
/// ```
class AutoSkeletonAppController {
  final ValueNotifier<bool> _loadingNotifier;

  /// Creates a controller with an optional initial loading state.
  AutoSkeletonAppController({bool initialLoading = false})
      : _loadingNotifier = ValueNotifier(initialLoading);

  /// Whether the skeleton is currently shown.
  bool get isLoading => _loadingNotifier.value;

  /// Show the skeleton overlay.
  void startLoading() => _loadingNotifier.value = true;

  /// Hide the skeleton and show content.
  void stopLoading() => _loadingNotifier.value = false;

  /// Toggle between loading and content.
  void toggle() => _loadingNotifier.value = !_loadingNotifier.value;

  /// A [NavigatorObserver] that automatically shows skeleton during
  /// route transitions.
  ///
  /// ```dart
  /// MaterialApp(
  ///   navigatorObservers: [controller.observer],
  /// )
  /// ```
  NavigatorObserver get observer => _AutoSkeletonNavigatorObserver(this);

  /// Dispose the controller when no longer needed.
  void dispose() => _loadingNotifier.dispose();
}

class _AutoSkeletonAppWidget extends StatelessWidget {
  final ValueNotifier<bool> loadingNotifier;
  final PlaceholderEffect? effect;
  final bool enableSwitchAnimation;
  final Widget child;

  const _AutoSkeletonAppWidget({
    required this.loadingNotifier,
    required this.effect,
    required this.enableSwitchAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loadingNotifier,
      builder: (context, isLoading, _) {
        return AutoSkeleton(
          enabled: isLoading,
          effect: effect,
          enableSwitchAnimation: enableSwitchAnimation,
          child: child,
        );
      },
    );
  }
}

/// Navigator observer that triggers skeleton on route transitions.
class _AutoSkeletonNavigatorObserver extends NavigatorObserver {
  final AutoSkeletonAppController _controller;

  _AutoSkeletonNavigatorObserver(this._controller);

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is ModalRoute) {
      _controller.startLoading();
      route.animation?.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.stopLoading();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute is ModalRoute) {
      _controller.startLoading();
      previousRoute.animation?.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _controller.stopLoading();
        }
      });
    }
  }
}
