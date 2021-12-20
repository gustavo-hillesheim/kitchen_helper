import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../presenter.dart';

class RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeListTile(
    this.recipe, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameText = Text(
      recipe.name,
      style: textTheme.headline6!.copyWith(
        fontWeight: FontWeight.w400,
      ),
    );
    final quantityProducedText = Text(
      'Produz ${Formatter.simple(recipe.quantityProduced)} '
      '${recipe.measurementUnit.label}',
      style: textTheme.subtitle2,
    );
    final widgets = <Widget>[
      nameText,
      kSmallSpacerVertical,
      quantityProducedText,
    ];
    if (recipe.canBeSold) {
      final quantitySold = recipe.quantitySold!;
      final price = recipe.price!;
      final quantitySoldText = Text(
        'Vende ${Formatter.simple(quantitySold)} '
        '${recipe.measurementUnit.label} '
        'por ${Formatter.money(price)}',
        style: textTheme.subtitle2,
      );
      widgets.add(kSmallSpacerVertical);
      widgets.add(quantitySoldText);
    }
    return FlatTile(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
