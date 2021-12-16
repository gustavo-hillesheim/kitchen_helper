import 'package:flutter/material.dart';

import '../constants.dart';

class FlatTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const FlatTile({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: kExtraSmallBorder,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(kMediumSpace),
            child: child,
          ),
        ),
      ),
    );
  }
}
