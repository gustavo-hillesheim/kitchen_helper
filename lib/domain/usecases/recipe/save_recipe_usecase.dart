import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../core/core.dart';
import '../../models/recipe.dart';
import '../../repository/repository.dart';

class SaveRecipeUseCase extends UseCase<Recipe, Recipe> {
  static const allIngredientsMustExistMessage = "É necessário salvar os "
      "ingredientes antes da receita";

  final IngredientRepository ingredientRepository;
  final RecipeRepository recipeRepository;

  SaveRecipeUseCase(this.ingredientRepository, this.recipeRepository);

  @override
  Future<Either<Failure, Recipe>> execute(Recipe recipe) async {
    return _validateIngredients(recipe.ingredients)
        .thenEither((_) => Right(recipe));
  }

  Future<Either<Failure, void>> _validateIngredients(
      List<RecipeIngredient> ingredients) async {
    for (final ingredient in ingredients) {
      final result = await _validateIngredient(ingredient);
      if (result.isLeft()) {
        return result;
      }
    }
    return const Right(null);
  }

  Future<Either<Failure, void>> _validateIngredient(
      RecipeIngredient ingredient) async {
    final existsResult = ingredient.type == RecipeIngredientType.ingredient
        ? await ingredientRepository.exists(ingredient.id)
        : await recipeRepository.exists(ingredient.id);
    if (existsResult.isLeft()) {
      return existsResult;
    }
    final exists = existsResult.getRight().getOrElse(() => false);
    if (!exists) {
      return const Left(BusinessFailure(allIngredientsMustExistMessage));
    }
    return const Right(null);
  }
}
