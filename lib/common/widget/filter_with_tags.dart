import 'package:flutter/material.dart';
import 'package:kitchen_helper/common/common.dart';

class FilterWithTags extends StatelessWidget {
  final VoidCallback? onOpenFilter;
  final List<Widget> tags;

  const FilterWithTags({
    super.key,
    this.onOpenFilter,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          child: IconButton(
            onPressed: onOpenFilter,
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filtrar',
            splashRadius: 24,
          ),
        ),
        kSmallSpacerHorizontal,
        Expanded(
          child: SizedBox(
            height: 24,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => tags[i],
              separatorBuilder: (_, __) => kSmallSpacerHorizontal,
              itemCount: tags.length,
            ),
          ),
        ),
      ],
    );
  }
}
