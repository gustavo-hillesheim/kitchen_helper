import 'package:flutter/material.dart';

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
    return SliverAppBar(
      floating: true,
      automaticallyImplyLeading: false,
      collapsedHeight: 75,
      expandedHeight: 200,
      titleSpacing: 0,
      flexibleSpace: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
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
        );
      }),
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
