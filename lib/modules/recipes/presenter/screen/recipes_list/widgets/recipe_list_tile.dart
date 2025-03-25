import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../recipes.dart';

class RecipeListTile extends StatelessWidget {
  final ListingRecipeDto recipe;
  final VoidCallback onTap;

  const RecipeListTile(
    this.recipe, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameText = AutoSizeText(
      recipe.name,
      style: textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w400,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    final quantityProducedText = Text(
      'Produz ${Formatter.simpleNumber(recipe.quantityProduced)} '
      '${recipe.measurementUnit.label}',
      style: textTheme.titleSmall,
    );
    final widgets = <Widget>[
      nameText,
      kSmallSpacerVertical,
      quantityProducedText,
    ];
    if (recipe.quantitySold != null && recipe.price != null) {
      final quantitySold = recipe.quantitySold!;
      final price = recipe.price!;
      final quantitySoldText = Text(
        'Vende ${Formatter.simpleNumber(quantitySold)} '
        '${recipe.measurementUnit.label} '
        'por ${Formatter.currency(price)}',
        style: textTheme.titleSmall,
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
