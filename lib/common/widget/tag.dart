import 'package:flutter/material.dart';

import '../constants.dart';

class Tag extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onDelete;

  const Tag({
    Key? key,
    required this.label,
    this.onDelete,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final efectiveColor = color ?? Theme.of(context).scaffoldBackgroundColor;
    return Container(
      padding: const EdgeInsets.all(kExtraSmallSpace),
      decoration: BoxDecoration(
        border: Border.all(color: efectiveColor),
        borderRadius: BorderRadius.circular(kSmallSpace),
        color: backgroundColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: efectiveColor)),
          if (onDelete != null) ...[
            kSmallSpacerHorizontal,
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close, size: 14),
            ),
          ]
        ],
      ),
    );
  }
}
