import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../ingredients.dart';

class IngredientListTile extends StatelessWidget {
  final ListingIngredientDto ingredient;
  final VoidCallback? onTap;

  const IngredientListTile(
    this.ingredient, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameText = AutoSizeText(
      ingredient.name,
      style: textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w400,
      ),
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
    final quantityText = Text(
      '${Formatter.simpleNumber(ingredient.quantity)} '
      '${ingredient.measurementUnit.label}',
      style: textTheme.titleSmall,
    );
    final priceText = Text(
      Formatter.currency(ingredient.cost),
      style: textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w300,
      ),
    );
    final ingredientInfo = Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameText,
              kSmallSpacerVertical,
              quantityText,
            ],
          ),
        ),
        kMediumSpacerHorizontal,
        priceText,
      ],
    );

    return FlatTile(
      child: ingredientInfo,
      onTap: onTap,
    );
  }
}
