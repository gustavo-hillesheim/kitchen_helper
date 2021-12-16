import '../../../../domain/domain.dart';

class EditingRecipeIngredient {
  final String name;
  final double quantity;
  final MeasurementUnit measurementUnit;
  final double cost;
  final RecipeIngredientType type;
  final int id;

  const EditingRecipeIngredient({
    required this.name,
    required this.quantity,
    required this.measurementUnit,
    required this.cost,
    required this.type,
    required this.id,
  });

  factory EditingRecipeIngredient.fromModels(
    RecipeIngredient recipeIngredient, {
    Ingredient? ingredient,
    Recipe? recipe,
    double? recipeCost,
  }) {
    String name;
    double cost;
    MeasurementUnit measurementUnit;
    final quantity = recipeIngredient.quantity;
    final type = recipeIngredient.type;
    final id = recipeIngredient.id;
    if (recipeIngredient.type == RecipeIngredientType.recipe) {
      recipe = recipe!;
      name = recipe.name;
      cost = recipeCost! * (quantity / recipe.quantityProduced);
      measurementUnit = recipe.measurementUnit;
    } else {
      ingredient = ingredient!;
      name = ingredient.name;
      cost = ingredient.cost * (quantity / ingredient.quantity);
      measurementUnit = ingredient.measurementUnit;
    }
    return EditingRecipeIngredient(
      name: name,
      quantity: quantity,
      measurementUnit: measurementUnit,
      cost: cost,
      type: type,
      id: id,
    );
  }
}
