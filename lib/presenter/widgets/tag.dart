import 'package:flutter/material.dart';

import '../constants.dart';

class Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const Tag({
    Key? key,
    required this.label,
    required this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kExtraSmallSpace),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(kSmallSpace),
        color: backgroundColor,
      ),
      child: Text(label, style: TextStyle(color: color)),
    );
  }
}
