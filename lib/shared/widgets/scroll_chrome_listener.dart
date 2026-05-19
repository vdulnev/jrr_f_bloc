import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/library/bloc/library_chrome_cubit.dart';

/// Wraps a scrollable and toggles [LibraryChromeCubit] so the library
/// chrome (header + tab bar) hides on scroll-down and shows on scroll-up.
///
/// Resets chrome to visible when this widget mounts or is disposed so a
/// tab that left chrome hidden doesn't leak the state to the next tab.
class ScrollChromeListener extends StatefulWidget {
  final Widget child;

  const ScrollChromeListener({required this.child, super.key});

  @override
  State<ScrollChromeListener> createState() => _ScrollChromeListenerState();
}

class _ScrollChromeListenerState extends State<ScrollChromeListener> {
  late final LibraryChromeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<LibraryChromeCubit>();
    Future.microtask(() {
      if (mounted) _cubit.set(true);
    });
  }

  @override
  void dispose() {
    // Defer to avoid emitting while a parent widget tree is being torn
    // down.
    Future.microtask(() => _cubit.set(true));
    super.dispose();
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is! UserScrollNotification) return false;

    switch (notification.direction) {
      case ScrollDirection.reverse:
        _cubit.set(false);
      case ScrollDirection.forward:
        _cubit.set(true);
      case ScrollDirection.idle:
        if (notification.metrics.pixels <= 0) _cubit.set(true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: widget.child,
    );
  }
}
