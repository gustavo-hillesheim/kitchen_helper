import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef HeaderBuilder = Widget Function(BuildContext context, double height);
typedef BeforeScrollCallback = bool Function(ScrollEvent event);

/// Used with a scrollable body, so that the header expands or collapses
/// according to the scroll.
class BodyWithHeader extends StatefulWidget {
  final Header header;
  final Widget body;

  const BodyWithHeader({
    Key? key,
    required this.header,
    required this.body,
  }) : super(key: key);

  @override
  _BodyWithHeaderState createState() => _BodyWithHeaderState();
}

class _BodyWithHeaderState extends State<BodyWithHeader> {
  late final scrollController = StoppableScrollController(
    beforeScroll: _handleScroll,
  );
  late double headerHeight = widget.header.maxHeight;

  bool _handleScroll(ScrollEvent scrollEvent) {
    if (scrollEvent.oldPixels != 0 || scrollEvent.maxScroll == 0) {
      return true;
    }
    final newHeaderHeight = _clamp(headerHeight + scrollEvent.delta,
        widget.header.minHeight, widget.header.maxHeight);
    if (headerHeight != newHeaderHeight) {
      setState(() {
        headerHeight = newHeaderHeight;
      });
    }
    final shouldScroll = headerHeight > widget.header.minHeight &&
        scrollEvent.direction == ScrollDirection.down;
    return !shouldScroll;
  }

  double _clamp(double value, double min, double max) {
    return math.max(math.min(value, max), min);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.only(top: headerHeight - 1),
            child: PrimaryScrollController(
              child: widget.body,
              controller: scrollController,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: widget.header.builder(context, headerHeight),
        ),
      ],
    );
  }
}

abstract class Header {
  double get minHeight;

  double get maxHeight;

  HeaderBuilder get builder;

  factory Header({
    required double minHeight,
    required double maxHeight,
    required HeaderBuilder builder,
  }) =>
      _PageHeaderImpl(
        minHeight: minHeight,
        maxHeight: maxHeight,
        builder: builder,
      );
}

class _PageHeaderImpl implements Header {
  @override
  final double minHeight;
  @override
  final double maxHeight;
  @override
  final HeaderBuilder builder;

  _PageHeaderImpl({
    required this.minHeight,
    required this.maxHeight,
    required this.builder,
  });
}

class StoppableScrollController extends ScrollController {
  final BeforeScrollCallback beforeScroll;

  StoppableScrollController({required this.beforeScroll});

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition? oldPosition) {
    return StoppableScrollPosition(
      physics: physics,
      context: context,
      beforeScroll: beforeScroll,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class StoppableScrollPosition extends ScrollPositionWithSingleContext {
  final BeforeScrollCallback beforeScroll;

  StoppableScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    required this.beforeScroll,
    double? initialPixels = 0.0,
    bool keepScrollOffset = true,
    ScrollPosition? oldPosition,
    String? debugLabel,
  }) : super(
          physics: physics,
          context: context,
          initialPixels: initialPixels,
          keepScrollOffset: keepScrollOffset,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        );

  @override
  double setPixels(double newPixels) {
    if (beforeScroll(ScrollEvent(pixels, newPixels, maxScrollExtent))) {
      return super.setPixels(newPixels);
    }
    return 0;
  }
}

class ScrollEvent {
  final double oldPixels;
  final double newPixels;
  final double maxScroll;

  double get delta => oldPixels - newPixels;

  ScrollDirection get direction =>
      delta < 0 ? ScrollDirection.down : ScrollDirection.up;

  ScrollEvent(this.oldPixels, this.newPixels, this.maxScroll);
}

enum ScrollDirection { down, up }
