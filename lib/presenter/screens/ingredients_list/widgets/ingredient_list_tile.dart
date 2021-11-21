import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/utils/formatter.dart';

import '../../../../domain/models/ingredient.dart';
import '../../../../domain/models/measurement_unit.dart';

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
            const SizedBox(height: 8),
            quantityText,
          ],
        ),
        const Spacer(),
        priceText,
      ],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      width: double.infinity,
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: ingredientInfo,
          ),
        ),
      ),
    );
  }
}
