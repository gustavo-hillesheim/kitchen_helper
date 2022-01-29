import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../domain/domain.dart';
import '../../extensions.dart';
import 'recipe_ingredient_selector.dart';

class RecipeIngredientSelectorService {
  final GetRecipesDomainUseCase getRecipesDomainUseCase;
  final GetIngredientsUseCase getIngredientsUseCase;

  RecipeIngredientSelectorService(
    this.getRecipesDomainUseCase,
    this.getIngredientsUseCase,
  );

  Future<Either<Failure, List<RecipeIngredientSelectorItem>>> getItems({
    int? recipeToIgnore,
    RecipeFilter? recipeFilter,
    RecipeIngredientSelectorItems? getOnly,
  }) async {
    final shouldGetRecipes =
        getOnly != RecipeIngredientSelectorItems.ingredients;
    final shouldGetIngredients =
        getOnly != RecipeIngredientSelectorItems.recipes;

    Either<Failure, List<RecipeDomainDto>> recipes = await _getRecipes(
      shouldGetRecipes,
      recipeFilter,
      recipeToIgnore,
    );
    Either<Failure, List<ListingIngredientDto>> ingredients =
        await _getIngredients(shouldGetIngredients);

    final items = recipes.combine(
      ingredients,
      (r, List<ListingIngredientDto> i) => _combineRecipesAndIngredients(r, i),
    );
    return items;
  }

  Future<Either<Failure, List<RecipeDomainDto>>> _getRecipes(
    bool shouldGet,
    RecipeFilter? recipeFilter,
    int? recipeToIgnore,
  ) async {
    return shouldGet
        ? (await getRecipesDomainUseCase.execute(RecipeDomainFilter(
            canBeSold: recipeFilter?.canBeSold,
            ignoreRecipesThatDependOn: recipeToIgnore,
          )))
        : const Right([]);
  }

  Future<Either<Failure, List<ListingIngredientDto>>> _getIngredients(
      bool shouldGet) async {
    return shouldGet
        ? (await getIngredientsUseCase.execute(const NoParams()))
        : const Right([]);
  }

  List<RecipeIngredientSelectorItem> _combineRecipesAndIngredients(
      List<RecipeDomainDto> recipes, List<ListingIngredientDto> ingredients) {
    final recipeItems = _recipesAsSelectorItems(recipes);
    final ingredientItems = _ingredientsAsSelectorItems(ingredients);
    final items = [...recipeItems, ...ingredientItems];
    items.sort(
      (i1, i2) => i1.name.toLowerCase().compareTo(i2.name.toLowerCase()),
    );
    return items;
  }

  Iterable<RecipeIngredientSelectorItem> _recipesAsSelectorItems(
      List<RecipeDomainDto> recipes) {
    return recipes.map((r) => RecipeIngredientSelectorItem(
          id: r.id,
          name: r.label,
          type: RecipeIngredientType.recipe,
          measurementUnit: r.measurementUnit,
        ));
  }

  Iterable<RecipeIngredientSelectorItem> _ingredientsAsSelectorItems(
    List<ListingIngredientDto> ingredients,
  ) {
    return ingredients.map((i) => RecipeIngredientSelectorItem(
          id: i.id,
          name: i.name,
          type: RecipeIngredientType.ingredient,
          measurementUnit: i.measurementUnit,
        ));
  }
}
