import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../models/recipe.dart';
import '../../repository/ingredient_repository.dart';

class SaveRecipeUseCase extends UseCase<Recipe, Recipe> {
  final IngredientRepository repository;

  SaveRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, Recipe>> execute(Recipe recipe) async {
    return _validateIngredients(recipe.ingredients)
        .thenEither((_) => Left(BusinessFailure('')));
  }

  Future<Either<Failure, void>> _validateIngredients(
      List<RecipeIngredient> ingredients) async {
    for (final ingredient in ingredients) {
      final result = await repository.exists(ingredient.id);
      if (result.isLeft()) {
        return result;
      }
    }
    return const Right(null);
  }
}
