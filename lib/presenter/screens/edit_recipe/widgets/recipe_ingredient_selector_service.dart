import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../domain/domain.dart';
import '../../../../extensions.dart';
import 'recipe_ingredient_selector.dart';

class RecipeIngredientSelectorService {
  final GetRecipeUseCase getRecipeUseCase;
  final GetRecipesUseCase getRecipesUseCase;
  final GetIngredientsUseCase getIngredientsUseCase;

  RecipeIngredientSelectorService(
    this.getRecipeUseCase,
    this.getRecipesUseCase,
    this.getIngredientsUseCase,
  );

  Future<Either<Failure, List<SelectorItem>>> getItems({
    int? recipeToIgnore,
  }) async {
    final recipes = await getRecipesUseCase.execute(const NoParams());
    final ingredients = await getIngredientsUseCase.execute(const NoParams());
    final items = recipes.combine(
      ingredients,
      (r, List<Ingredient> i) => _combineRecipesAndIngredients(r, i),
    );
    return items.asyncFlatMap((items) async {
      if (recipeToIgnore != null) {
        return _deepRemoveIgnoredRecipe(items, recipeToIgnore)
            .onRightThen((_) => Right(items));
      }
      return Right(items);
    });
  }

  List<SelectorItem> _combineRecipesAndIngredients(
      List<Recipe> recipes, List<Ingredient> ingredients) {
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

  Future<Either<Failure, void>> _deepRemoveIgnoredRecipe(
    List<SelectorItem> items,
    int ignoredRecipe,
  ) async {
    try {
      final itemsToRemove = <SelectorItem>[];
      for (final item in items) {
        if (item.type != RecipeIngredientType.recipe) {
          continue;
        }
        if (item.id == ignoredRecipe) {
          itemsToRemove.add(item);
        }
        final dependsOnRecipe =
            await _dependsOnRecipe(item.id, ignoredRecipe).throwOnFailure();
        if (dependsOnRecipe) {
          itemsToRemove.add(item);
        }
      }
      for (var item in itemsToRemove) {
        items.remove(item);
      }
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    }
  }

  Future<Either<Failure, bool>> _dependsOnRecipe(
    int parentRecipeId,
    int recipeId,
  ) async {
    final recipe =
        await getRecipeUseCase.execute(parentRecipeId).throwOnFailure();
    if (recipe == null) {
      return const Right(false);
    }
    var dependsOnRecipe = false;
    for (final ingredient in recipe.ingredients) {
      if (ingredient.type != RecipeIngredientType.recipe) {
        continue;
      }
      if (ingredient.id == recipeId) {
        dependsOnRecipe = true;
      } else {
        dependsOnRecipe =
            await _dependsOnRecipe(ingredient.id, recipeId).throwOnFailure();
      }
      if (dependsOnRecipe) {
        break;
      }
    }
    return Right(dependsOnRecipe);
  }
}
