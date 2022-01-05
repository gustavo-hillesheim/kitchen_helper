import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/models/editing_recipe_ingredient.dart';

import '../../../../mocks.dart';

void main() {
  test('SHOULD create EditingRecipeIngredient from recipe', () {
    final result = EditingRecipeIngredient.fromModels(
      RecipeIngredient.recipe(
        cakeRecipe.id!,
        quantity: cakeRecipe.quantitySold!,
      ),
      recipe: cakeRecipe,
      recipeCost: 100,
    );

    expect(
      result,
      EditingRecipeIngredient(
        id: cakeRecipe.id!,
        type: RecipeIngredientType.recipe,
        measurementUnit: cakeRecipe.measurementUnit,
        quantity: cakeRecipe.quantitySold!,
        name: cakeRecipe.name,
        cost: 100,
      ),
    );
  });
  test('SHOULD create EditingRecipeIngredient from ingredient', () {
    final result = EditingRecipeIngredient.fromModels(
      RecipeIngredient.ingredient(egg.id!, quantity: egg.quantity),
      ingredient: egg,
    );

    expect(
      result,
      EditingRecipeIngredient(
        id: egg.id!,
        type: RecipeIngredientType.ingredient,
        measurementUnit: egg.measurementUnit,
        quantity: egg.quantity,
        name: egg.name,
        cost: egg.cost,
      ),
    );
  });
}
