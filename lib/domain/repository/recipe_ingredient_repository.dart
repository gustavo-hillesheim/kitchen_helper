import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../domain.dart';

abstract class RecipeIngredientRepository
    extends Repository<RecipeIngredientEntity, int> {
  Future<Either<Failure, int?>> findId(
      Recipe recipe, RecipeIngredient recipeIngredient);

  Future<Either<Failure, List<RecipeIngredientEntity>>> findByRecipe(
      int recipeId);
}
