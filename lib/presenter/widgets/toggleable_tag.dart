import 'package:flutter/material.dart';

import '../presenter.dart';

class ToggleableTag extends StatefulWidget {
  final String label;
  final bool? value;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<bool> onChange;

  const ToggleableTag({
    Key? key,
    required this.label,
    required this.onChange,
    this.value,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  _ToggleableTagState createState() => _ToggleableTagState();
}

class _ToggleableTagState extends State<ToggleableTag> {
  var _isActive = false;

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
        widget.inactiveColor ?? Theme.of(context).colorScheme.primary;
    final activeColor =
        widget.activeColor ?? Theme.of(context).scaffoldBackgroundColor;
    final isActive = widget.value ?? _isActive;
    final foregroundColor = isActive ? inactiveColor : activeColor;
    final backgroundColor = isActive ? activeColor : inactiveColor;

    return Stack(
      children: [
        Tag(
          label: widget.label,
          color: foregroundColor,
          backgroundColor: backgroundColor,
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() {
                _isActive = !isActive;
                widget.onChange(_isActive);
              }),
              borderRadius: BorderRadius.circular(kSmallSpace),
              splashColor: foregroundColor.withOpacity(0.2),
            ),
          ),
        )
      ],
    );
  }
}
