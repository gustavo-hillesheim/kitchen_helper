import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const SecondaryButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
