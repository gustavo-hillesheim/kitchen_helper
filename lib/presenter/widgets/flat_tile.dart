import 'package:flutter/material.dart';

import '../constants.dart';

class FlatTile extends StatelessWidget {
  static const defaultPadding = EdgeInsets.all(kMediumSpace);

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const FlatTile({
    Key? key,
    required this.child,
    this.padding = defaultPadding,
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
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
