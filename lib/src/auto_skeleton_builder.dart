import 'package:flutter/material.dart';
import 'smart_placeholder.dart';
import 'effects/placeholder_effect.dart';

/// Handles async data loading with automatic skeleton display.
///
/// No `setState`, no `_isLoading` boolean — just provide a [future]
/// and a [builder]. The skeleton is shown automatically while loading.
///
/// ## Basic Usage
///
/// ```dart
/// AutoSkeletonBuilder<User>(
///   future: fetchUser(),
///   skeleton: ListTile(
///     leading: CircleAvatar(child: Icon(Icons.person)),
///     title: Text('Placeholder'),
///     subtitle: Text('Loading...'),
///   ),
///   builder: (context, data) => ListTile(
///     leading: CircleAvatar(backgroundImage: NetworkImage(data.avatar)),
///     title: Text(data.name),
///     subtitle: Text(data.bio),
///   ),
/// )
/// ```
///
/// ## With Stream
///
/// ```dart
/// AutoSkeletonBuilder<List<Post>>(
///   stream: postStream(),
///   skeleton: Column(children: List.generate(3, (_) => PostCardSkeleton())),
///   builder: (context, posts) => Column(
///     children: posts.map((p) => PostCard(p)).toList(),
///   ),
/// )
/// ```
///
/// ## With Error Handling
///
/// ```dart
/// AutoSkeletonBuilder<User>(
///   future: fetchUser(),
///   skeleton: ProfileSkeleton(),
///   builder: (context, data) => ProfileCard(data),
///   errorBuilder: (context, error) => ErrorCard(error.toString()),
/// )
/// ```
class AutoSkeletonBuilder<T> extends StatefulWidget {
  /// The async data source. Provide either [future] or [stream], not both.
  final Future<T>? future;

  /// The stream data source. Provide either [future] or [stream], not both.
  final Stream<T>? stream;

  /// The widget tree used as the skeleton shape while loading.
  /// This widget is rendered invisibly and scanned for bone shapes.
  final Widget skeleton;

  /// Builds the real content once data is available.
  final Widget Function(BuildContext context, T data) builder;

  /// Optional error widget builder. If not provided, shows the skeleton
  /// on error (so you can handle errors yourself upstream).
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Optional loading widget shown while [future]/[stream] has no data yet.
  /// If not provided, the [skeleton] with shimmer effect is shown.
  final Widget? loading;

  /// Override the painting effect (shimmer, pulse, solid).
  final PlaceholderEffect? effect;

  /// Whether to animate the transition from skeleton to content.
  final bool enableSwitchAnimation;

  /// Duration of the switch animation.
  final Duration switchAnimationDuration;

  /// Callback when data is successfully loaded.
  final void Function(T data)? onData;

  /// Callback when an error occurs.
  final void Function(Object error)? onError;

  const AutoSkeletonBuilder({
    super.key,
    this.future,
    this.stream,
    required this.skeleton,
    required this.builder,
    this.errorBuilder,
    this.loading,
    this.effect,
    this.enableSwitchAnimation = true,
    this.switchAnimationDuration = const Duration(milliseconds: 300),
    this.onData,
    this.onError,
  }) : assert(
          (future != null) != (stream != null),
          'Provide either future or stream, not both.',
        );

  @override
  State<AutoSkeletonBuilder<T>> createState() => _AutoSkeletonBuilderState<T>();
}

class _AutoSkeletonBuilderState<T> extends State<AutoSkeletonBuilder<T>> {
  late _AsyncState<T> _state;

  @override
  void initState() {
    super.initState();
    _state = _AsyncState<T>.loading();
    _subscribe();
  }

  @override
  void didUpdateWidget(AutoSkeletonBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-subscribe if the future/stream reference changed.
    if (widget.future != oldWidget.future || widget.stream != oldWidget.stream) {
      _state = _AsyncState<T>.loading();
      _subscribe();
    }
  }

  void _subscribe() {
    if (widget.future != null) {
      widget.future!.then(
        (data) {
          if (mounted) {
            setState(() => _state = _AsyncState<T>.data(data));
            widget.onData?.call(data);
          }
        },
        onError: (Object error) {
          if (mounted) {
            setState(() => _state = _AsyncState<T>.error(error));
            widget.onError?.call(error);
          }
        },
      );
    } else if (widget.stream != null) {
      widget.stream!.listen(
        (data) {
          if (mounted) {
            setState(() => _state = _AsyncState<T>.data(data));
            widget.onData?.call(data);
          }
        },
        onError: (Object error) {
          if (mounted) {
            setState(() => _state = _AsyncState<T>.error(error));
            widget.onError?.call(error);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _AsyncLoading<T>() => AutoSkeleton(
          enabled: true,
          effect: widget.effect,
          enableSwitchAnimation: widget.enableSwitchAnimation,
          switchAnimationDuration: widget.switchAnimationDuration,
          child: widget.loading ?? widget.skeleton,
        ),
      _AsyncData<T>(data: final data) => AutoSkeleton(
          enabled: false,
          effect: widget.effect,
          enableSwitchAnimation: widget.enableSwitchAnimation,
          switchAnimationDuration: widget.switchAnimationDuration,
          child: widget.builder(context, data),
        ),
      _AsyncError<T>(error: final error) => widget.errorBuilder != null
          ? widget.errorBuilder!(context, error)
          : AutoSkeleton(
              enabled: true,
              effect: widget.effect,
              child: widget.skeleton,
            ),
    };
  }
}

/// Internal async state representation.
sealed class _AsyncState<T> {
  const _AsyncState();
  factory _AsyncState.loading() = _AsyncLoading<T>;
  factory _AsyncState.data(T data) = _AsyncData<T>;
  factory _AsyncState.error(Object error) = _AsyncError<T>;
}

class _AsyncLoading<T> extends _AsyncState<T> {
  const _AsyncLoading();
}

class _AsyncData<T> extends _AsyncState<T> {
  final T data;
  const _AsyncData(this.data);
}

class _AsyncError<T> extends _AsyncState<T> {
  final Object error;
  const _AsyncError(this.error);
}
