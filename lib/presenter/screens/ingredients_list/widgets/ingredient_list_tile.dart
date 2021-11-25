import 'package:flutter/material.dart';

import '../../../../domain/models/ingredient.dart';
import '../../../../domain/models/measurement_unit.dart';
import '../../../constants.dart';
import '../../../utils/formatter.dart';

class IngredientListTile extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientListTile(
    this.ingredient, {
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
      Formatter.price(ingredient.price),
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: kSmallSpace),
      width: double.infinity,
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: kExtraSmallBorder,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(kMediumSpace - 2.0),
            child: ingredientInfo,
          ),
        ),
      ),
    );
  }
}
