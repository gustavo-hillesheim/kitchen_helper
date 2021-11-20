import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PageDescriptionTile extends StatefulWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const PageDescriptionTile({
    Key? key,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  _PageDescriptionTileState createState() => _PageDescriptionTileState();
}

class _PageDescriptionTileState extends State<PageDescriptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _elevationController;
  static const _contentColor = Colors.white;

  @override
  initState() {
    super.initState();
    _elevationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: 1,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _elevationController,
      builder: (_, elevation, __) => Container(
        height: 100,
        margin: const EdgeInsets.all(16),
        decoration: _buildDecoration(elevation),
        child: _buildInkWell(_buildContent()),
      ),
    );
  }

  BoxDecoration _buildDecoration(double elevation) => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: widget.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            spreadRadius: 2 * elevation,
            blurRadius: 6 * elevation,
            offset: Offset(0, 4 * elevation),
          ),
        ],
      );

  Widget _buildInkWell(Widget child) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _elevationController.forward();
          },
          onTapDown: (_) => _elevationController.reverse(),
          onTapCancel: () => _elevationController.forward(),
          child: child,
        ),
      );

  Widget _buildContent() => Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildIcon(),
            Expanded(
              child: _buildPageInfo(),
            ),
            const SizedBox(width: 64),
          ],
        ),
      );

  Widget _buildIcon() => LayoutBuilder(
        builder: (_, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
              child: FittedBox(child: Icon(widget.icon, color: _contentColor)),
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
              color: _contentColor,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            style: const TextStyle(color: _contentColor),
          ),
        ],
      );
}
