import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';

class Expandable extends StatefulWidget {
  final Widget? top;

  // Being a WidgetBuilder allows us to build the flexible lazily
  final WidgetBuilder flexibleBuilder;
  final Widget? bottom;

  const Expandable({
    Key? key,
    required this.flexibleBuilder,
    this.top,
    this.bottom,
  }) : super(key: key);

  @override
  _ExpandableState createState() => _ExpandableState();
}

class _ExpandableState extends State<Expandable>
    with SingleTickerProviderStateMixin {
  late final expansionController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  var _isExpanding = false;

  @override
  void dispose() {
    expansionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.top != null) widget.top!,
              if (widget.top != null) kExtraSmallSpacerVertical,
              ClipRect(
                child: AnimatedBuilder(
                    animation: expansionController,
                    builder: (context, _) {
                      if (expansionController.value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Align(
                        alignment: Alignment.topLeft,
                        heightFactor: expansionController.value,
                        child: widget.flexibleBuilder(context),
                      );
                    }),
              ),
              if (widget.bottom != null) kExtraSmallSpacerVertical,
              if (widget.bottom != null) widget.bottom!,
            ],
          ),
        ),
        kSmallSpacerHorizontal,
        AnimatedBuilder(
            animation: expansionController,
            builder: (context, _) {
              return IconButton(
                visualDensity: VisualDensity.compact,
                splashRadius: 24,
                icon: Transform(
                  transform: Matrix4.identity()
                    ..rotateZ(pi * expansionController.value),
                  alignment: Alignment.center,
                  child: const Icon(Icons.expand_more),
                ),
                onPressed: () {
                  if (_isExpanding) {
                    expansionController.reverse();
                  } else {
                    expansionController.forward();
                  }
                  _isExpanding = !_isExpanding;
                },
              );
            }),
      ],
    );
  }
}
