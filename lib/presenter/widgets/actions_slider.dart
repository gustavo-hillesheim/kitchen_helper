import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ActionsSlider extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDelete;

  const ActionsSlider({
    Key? key,
    required this.child,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      closeOnScroll: true,
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const DrawerMotion(),
        children: [
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete!(),
              icon: Icons.delete,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              label: 'Excluir',
            ),
        ],
      ),
      child: child,
    );
  }
}
