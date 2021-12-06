import 'package:flutter/material.dart';

import '../presenter.dart';

class Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? subtext;
  final Widget? action;

  const Empty({
    Key? key,
    required this.text,
    this.icon = Icons.no_food_outlined,
    this.subtext,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: kExtraLargeSpace),
        kLargeSpacerVertical,
        Text(
          text,
          style: textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (subtext != null) ...{
          kMediumSpacerVertical,
          Text(
            subtext!,
            style: textTheme.subtitle1,
            textAlign: TextAlign.center,
          ),
        },
        if (action != null) ...{
          kLargeSpacerVertical,
          action!,
        }
      ],
    );
  }
}
