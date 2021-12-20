import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../constants.dart';
import '../../../utils/formatter.dart';
import '../../../widgets/widgets.dart';

class IngredientListTile extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;

  const IngredientListTile(
    this.ingredient, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameText = Text(
      ingredient.name,
      style: textTheme.headline6!.copyWith(
        fontWeight: FontWeight.w400,
      ),
    );
    final quantityText = Text(
      '${Formatter.simple(ingredient.quantity)} '
      '${ingredient.measurementUnit.label}',
      style: textTheme.subtitle2,
    );
    final priceText = Text(
      Formatter.money(ingredient.cost),
      style: textTheme.headline5!.copyWith(
        fontWeight: FontWeight.w300,
      ),
    );
    final ingredientInfo = Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            nameText,
            kSmallSpacerVertical,
            quantityText,
          ],
        ),
        const Spacer(),
        priceText,
      ],
    );

    return FlatTile(
      child: ingredientInfo,
      onTap: onTap,
    );
  }
}
