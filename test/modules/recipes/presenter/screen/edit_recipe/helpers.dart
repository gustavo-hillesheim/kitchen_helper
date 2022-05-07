import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/models/editing_recipe_ingredient.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';

import '../../../../../finders.dart';
import '../../../../../mocks.dart';

final quantityProducedFieldFinder = AppTextFormFieldFinder(
  name: 'Quantidade produzida',
  type: TextInputType.number,
);
final measurementUnitSelectorFinder = find.byType(MeasurementUnitSelector);
final notesFieldFinder = AppTextFormFieldFinder(name: 'Anotações');
final canBeSoldFieldFinder = find.byType(CheckboxListTile);
final quantitySoldFieldFinder = AppTextFormFieldFinder(
  name: 'Quantidade vendida',
  type: TextInputType.number,
);
final priceFieldFinder = AppTextFormFieldFinder(
  name: 'Preço de venda',
  type: TextInputType.number,
  prefix: 'R\$',
);

Future<void> fillGeneralInformationForm(
  WidgetTester tester, {
  bool? canBeSold,
  String? notes,
  MeasurementUnit? measurementUnit,
  double? quantityProduced,
  double? quantitySold,
  double? price,
}) async {
  if (canBeSold ?? false) {
    await tester.tap(canBeSoldFieldFinder);
    await tester.pumpAndSettle();
  }
  if (quantityProduced != null) {
    await tester.enterText(
        quantityProducedFieldFinder, Formatter.simpleNumber(quantityProduced));
  }
  if (notes != null) {
    await tester.enterText(notesFieldFinder, notes);
  }
  if (quantitySold != null) {
    await tester.enterText(
        quantitySoldFieldFinder, Formatter.simpleNumber(quantitySold));
  }
  if (price != null) {
    await tester.enterText(priceFieldFinder, Formatter.simpleNumber(price));
  }
  if (measurementUnit != null) {
    await tester.tap(measurementUnitSelectorFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text(measurementUnit.label).last);
    await tester.pumpAndSettle();
  }
}

Future<void> addIngredient(
  WidgetTester tester, {
  double? quantity,
  String? ingredientName,
}) async {
  await tester.tap(find.text('Adicionar ingrediente').last);
  await tester.pump();

  if (quantity != null) {
    await tester.enterText(
      AppTextFormFieldFinder(
        name: 'Quantidade',
        type: TextInputType.number,
      ),
      Formatter.simpleNumber(quantity),
    );
  }
  if (ingredientName != null) {
    await tester.tap(find.byType(RecipeIngredientSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ingredientName));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Adicionar').last);
}

List<EditingRecipeIngredient> editingRecipeIngredients(Recipe recipe) {
  return recipe.ingredients.map((ingredient) {
    return EditingRecipeIngredient.fromModels(
      ingredient,
      ingredient: ingredientsMap[ingredient.id],
    );
  }).toList();
}
