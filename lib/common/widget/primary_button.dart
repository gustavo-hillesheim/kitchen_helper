import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      minimumSize: MaterialStateProperty.all(
        const Size.fromHeight(48),
      ),
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.secondary,
      ),
    );

    if (isLoading) {
      return ElevatedButton(
        style: buttonStyle,
        onPressed: null,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    return ElevatedButton(
      style: buttonStyle,
      onPressed: onPressed,
      child: child,
    );
  }
}
