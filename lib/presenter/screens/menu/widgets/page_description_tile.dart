import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../constants.dart';

class PageDescriptionTile extends StatefulWidget {
  final String name;
  final String description;
  final String route;
  final IconData icon;
  final MaterialColor color;

  const PageDescriptionTile({
    Key? key,
    required this.name,
    required this.description,
    required this.route,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  _PageDescriptionTileState createState() => _PageDescriptionTileState();
}

class _PageDescriptionTileState extends State<PageDescriptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _elevationController;

  @override
  initState() {
    super.initState();
    _elevationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: 1,
      duration: kFastDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _elevationController,
      builder: (_, elevation, __) => Container(
        height: 100,
        margin: kMediumEdgeInsets,
        decoration: _buildDecoration(elevation),
        child: _buildInkWell(_buildContent()),
      ),
    );
  }

  BoxDecoration _buildDecoration(double elevation) => BoxDecoration(
        borderRadius: kMediumBorder,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            spreadRadius: 0.5 * elevation,
            blurRadius: 1 * elevation,
            offset: Offset(0, 1 * elevation),
          ),
        ],
      );

  Widget _buildInkWell(Widget child) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: kMediumBorder,
          onTap: () {
            Modular.to.pushNamed(widget.route);
            _elevationController.forward();
          },
          onTapDown: (_) => _elevationController.reverse(),
          onTapCancel: () => _elevationController.forward(),
          child: child,
        ),
      );

  Widget _buildContent() => Padding(
        padding: kSmallEdgeInsets,
        child: Row(
          children: [
            _buildIcon(),
            Expanded(
              child: _buildPageInfo(),
            ),
            kExtraLargeSpacerVertical,
          ],
        ),
      );

  Widget _buildIcon() => LayoutBuilder(
        builder: (_, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                kMediumSpace,
                kMediumSpace,
                kMediumSpace,
              ),
              child: FittedBox(child: Icon(widget.icon)),
            ),
          );
        },
      );

  Widget _buildPageInfo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.name,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: kLargeFontSize,
            ),
          ),
          kSmallSpacerVertical,
          Text(widget.description),
        ],
      );
}
