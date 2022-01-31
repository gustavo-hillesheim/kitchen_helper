import 'package:flutter/material.dart';

import '../constants.dart';

class BottomCard extends StatelessWidget {
  final Widget child;

  const BottomCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.vertical(top: kMediumRadius),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
    );
  }
}
