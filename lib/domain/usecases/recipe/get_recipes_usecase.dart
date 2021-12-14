import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class GetRecipesUseCase extends UseCase<NoParams, List<Recipe>> {
  final RecipeRepository recipeRepository;
  final RecipeIngredientRepository recipeIngredientRepository;

  GetRecipesUseCase(this.recipeRepository, this.recipeIngredientRepository);

  @override
  Future<Either<Failure, List<Recipe>>> execute(NoParams input) {
    return recipeRepository.findAll().onRightThen((recipes) async {
      final newRecipes = <Recipe>[];
      for (final recipe in recipes) {
        final findIngredientsResult =
            await recipeIngredientRepository.findByRecipe(recipe.id!);
        if (findIngredientsResult.isLeft()) {
          return findIngredientsResult.asLeftOf();
        }
        final ingredients = _getIngredients(findIngredientsResult);
        newRecipes.add(recipe.copyWith(ingredients: ingredients));
      }
      return Right(newRecipes);
    });
  }

  List<RecipeIngredient> _getIngredients(
      Either<Failure, List<RecipeIngredientEntity>> entitiesResult) {
    return entitiesResult
        .getRight()
        .toNullable()!
        .map((i) => i.toRecipeIngredient())
        .toList();
  }
}
