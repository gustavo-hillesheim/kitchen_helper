import 'package:flutter/material.dart';

class SliverScreenBar extends StatelessWidget {
  final String title;

  const SliverScreenBar({Key? key, required this.title}) : super(key: key);

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
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.add),
                  label: Text('Adicionar'),
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
