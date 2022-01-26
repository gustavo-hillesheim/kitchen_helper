import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'body_with_header.dart';

class AppBarHeader implements Header {
  final String title;
  final AppBarHeaderAction? action;
  final Widget? bottom;
  @override
  final double maxHeight = 250;
  @override
  final double minHeight;

  @override
  HeaderBuilder get builder => build;

  AppBarHeader({
    required this.title,
    required BuildContext context,
    this.action,
    this.bottom,
  }) : minHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

  Widget build(BuildContext context, double availableHeight) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: Container(
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
                      kMediumSpacerHorizontal,
                      if (action != null) _buildAction(),
                    ],
                  ),
                ),
              ),
              if (canPop)
                const Positioned(
                  top: 4,
                  left: 4,
                  child: BackButton(),
                ),
              if (bottom != null)
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  child: bottom!,
                ),
            ],
          ),
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
    final expandedFontSize = textTheme.headline6!.fontSize! * 1.5;
    final collapsedFontSize = textTheme.headline6!.fontSize!;
    const expandedPadding = 0;
    const collapsedPadding = kBackButtonSize;
    final fontSize = collapsedFontSize +
        (expandedFontSize - collapsedFontSize) * animationProgress;

    return Padding(
      padding: EdgeInsets.only(
        left: collapsedPadding +
            (expandedPadding - collapsedPadding) * animationProgress,
      ),
      child: AutoSizeText(
        title,
        style: Theme.of(context).textTheme.headline4!.copyWith(
              color: Colors.white,
            ),
        maxFontSize: fontSize.roundToDouble(),
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

class AppBarHeaderAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  AppBarHeaderAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}
