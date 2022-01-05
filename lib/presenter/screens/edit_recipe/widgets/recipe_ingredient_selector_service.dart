import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../domain/domain.dart';
import 'recipe_ingredient_selector.dart';

class RecipeIngredientSelectorService {
  final GetRecipesUseCase getRecipesUseCase;
  final GetIngredientsUseCase getIngredientsUseCase;

  RecipeIngredientSelectorService(
    this.getRecipesUseCase,
    this.getIngredientsUseCase,
  );

  Future<Either<Failure, List<SelectorItem>>> getItems() async {
    final recipes = await getRecipesUseCase.execute(const NoParams());
    final ingredients = await getIngredientsUseCase.execute(const NoParams());
    return recipes.combine(
      ingredients,
      (r, List<Ingredient> i) => _combineRecipesAndIngredients(r, i),
    );
  }

  List<SelectorItem> _combineRecipesAndIngredients(
    List<Recipe> recipes,
    List<Ingredient> ingredients,
  ) {
    final recipeItems = _recipesAsSelectorItems(recipes);
    final ingredientItems = _ingredientsAsSelectorItems(ingredients);
    final items = [...recipeItems, ...ingredientItems];
    items.sort(
      (i1, i2) => i1.name.toLowerCase().compareTo(i2.name.toLowerCase()),
    );
    return items;
  }

  Iterable<SelectorItem> _recipesAsSelectorItems(List<Recipe> recipes) {
    return recipes.map((r) => SelectorItem(
          id: r.id!,
          name: r.name,
          type: RecipeIngredientType.recipe,
          measurementUnit: r.measurementUnit,
        ));
  }

  Iterable<SelectorItem> _ingredientsAsSelectorItems(
    List<Ingredient> ingredients,
  ) {
    return ingredients.map((i) => SelectorItem(
          id: i.id!,
          name: i.name,
          type: RecipeIngredientType.ingredient,
          measurementUnit: i.measurementUnit,
        ));
  }
}
