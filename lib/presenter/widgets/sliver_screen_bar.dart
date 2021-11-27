import 'package:flutter/material.dart';

import '../constants.dart';

class SliverScreenBar extends StatelessWidget {
  final String title;
  final SliverScreenBarAction? action;

  const SliverScreenBar({
    Key? key,
    required this.title,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: kMediumEdgeInsets,
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Colors.white,
                    ),
              ),
              const Spacer(),
              if (action != null)
                TextButton.icon(
                  onPressed: action!.onPressed,
                  icon: Icon(action!.icon),
                  label: Text(action!.label),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    overlayColor: MaterialStateProperty.all(
                        Colors.white.withOpacity(0.1)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverScreenBarAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  SliverScreenBarAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}
