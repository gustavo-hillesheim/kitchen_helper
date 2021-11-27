import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef HeaderBuilder = Widget Function(BuildContext context, double height);
typedef BeforeScrollCallback = bool Function(ScrollEvent event);

class PageTemplate extends StatefulWidget {
  final HeaderBuilder headerBuilder;
  final Widget body;
  final double maxHeaderHeight;

  const PageTemplate({
    Key? key,
    required this.headerBuilder,
    required this.body,
    required this.maxHeaderHeight,
  }) : super(key: key);

  @override
  _PageTemplateState createState() => _PageTemplateState();
}

class _PageTemplateState extends State<PageTemplate> {
  late final scrollController = StoppableScrollController(
    beforeScroll: _handleScroll,
  );
  late double headerHeight = widget.maxHeaderHeight;

  bool _handleScroll(ScrollEvent scrollEvent) {
    if (scrollEvent.oldPixels != 0 || scrollEvent.maxScroll == 0) {
      return true;
    }
    final newHeaderHeight =
        _clamp(headerHeight + scrollEvent.delta, 0, widget.maxHeaderHeight);
    if (headerHeight != newHeaderHeight) {
      setState(() {
        headerHeight = newHeaderHeight;
      });
    }
    final shouldScroll =
        headerHeight > 0 && scrollEvent.direction == ScrollDirection.down;
    return !shouldScroll;
  }

  double _clamp(double value, double min, double max) {
    return math.max(math.min(value, max), min);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: headerHeight),
          child: PrimaryScrollController(
            child: widget.body,
            controller: scrollController,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: headerHeight,
          child: widget.headerBuilder(context, headerHeight),
        ),
      ],
    );
  }
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
