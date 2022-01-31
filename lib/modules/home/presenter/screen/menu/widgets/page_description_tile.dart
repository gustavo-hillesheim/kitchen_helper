import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../../common/common.dart';

class PageDescriptionTile extends StatefulWidget {
  final String name;
  final String description;
  final String route;
  final IconData icon;

  const PageDescriptionTile({
    Key? key,
    required this.name,
    required this.description,
    required this.route,
    required this.icon,
  }) : super(key: key);

  @override
  _PageDescriptionTileState createState() => _PageDescriptionTileState();
}

class _PageDescriptionTileState extends State<PageDescriptionTile>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kSmallEdgeInsets.copyWith(bottom: 0),
      child: FlatTile(
        onTap: () => Modular.to.pushNamed(widget.route),
        child: Row(
          children: [
            Center(
              child: Icon(widget.icon, size: 40),
            ),
            kMediumSpacerHorizontal,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    widget.name,
                    style: Theme.of(context).textTheme.headline6,
                    maxFontSize:
                        Theme.of(context).textTheme.headline6!.fontSize!,
                  ),
                  kExtraSmallSpacerVertical,
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
