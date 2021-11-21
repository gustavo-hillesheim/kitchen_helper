import 'package:flutter/material.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';

import '../../../../domain/models/ingredient.dart';

class IngredientListTile extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientListTile(
    this.ingredient, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 80,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ingredient.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatQuantity(ingredient.quantity)} '
                      '${measurementUnitLabel(ingredient.measurementUnit)}',
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  formatPrice(ingredient.price),
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatPrice(double price) {
  return 'R\$${price.toStringAsFixed(2)}';
}

String formatQuantity(double quantity) {
  var quantityStr = quantity.toString();
  while (quantityStr.contains('.') &&
      (quantityStr.endsWith('0') || quantityStr.endsWith('.'))) {
    quantityStr = quantityStr.substring(0, quantityStr.length - 1);
  }
  return quantityStr;
}

String measurementUnitLabel(MeasurementUnit measurementUnit) {
  switch (measurementUnit) {
    case MeasurementUnit.grams:
      return 'gramas';
    case MeasurementUnit.kilograms:
      return 'kilogramas';
    case MeasurementUnit.liters:
      return 'litros';
    case MeasurementUnit.milliliters:
      return 'mililitros';
    case MeasurementUnit.units:
      return 'unidades';
  }
}
