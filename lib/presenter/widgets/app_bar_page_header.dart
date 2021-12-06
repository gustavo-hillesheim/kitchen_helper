import 'package:flutter/material.dart';

import '../constants.dart';
import 'page_template.dart';

class AppBarPageHeader implements PageHeader {
  final String title;
  final AppBarPageHeaderAction? action;
  @override
  final double maxHeight = 250;
  @override
  final double minHeight;
  @override
  HeaderBuilder get builder => build;

  AppBarPageHeader({
    required this.title,
    required BuildContext context,
    this.action,
  }) : minHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

  Widget build(BuildContext context, double availableHeight) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kLargeSpace),
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTitle(context, availableHeight),
                    const Spacer(),
                    if (action != null) _buildAction(),
                  ],
                ),
              ),
            ),
            if (canPop)
              const Positioned(
                top: 4,
                left: 4,
                child: BackButton(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  double _animationProgress(double availableHeight) {
    return (availableHeight - minHeight) / (maxHeight - minHeight);
  }

  Widget _buildTitle(BuildContext context, double availableHeight) {
    final textTheme = Theme.of(context).textTheme;
    const kBackButtonSize = 24;
    final animationProgress = _animationProgress(availableHeight);
    final expandedFontSize = textTheme.headline4!.fontSize!;
    final collapsedFontSize = textTheme.headline6!.fontSize!;
    const expandedPadding = 0;
    const collapsedPadding = kBackButtonSize;

    return Padding(
      padding: EdgeInsets.only(
          left: collapsedPadding +
              (expandedPadding - collapsedPadding) * animationProgress),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline4!.copyWith(
              fontSize: collapsedFontSize +
                  (expandedFontSize - collapsedFontSize) * animationProgress,
              color: Colors.white,
            ),
      ),
    );
  }

  Widget _buildAction() => TextButton.icon(
        onPressed: action!.onPressed,
        icon: Icon(action!.icon),
        label: Text(action!.label),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white),
          overlayColor:
              MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
      );
}

class AppBarPageHeaderAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  AppBarPageHeaderAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}
