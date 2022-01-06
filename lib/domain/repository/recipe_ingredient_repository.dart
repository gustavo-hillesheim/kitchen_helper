import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../database/database.dart';
import '../domain.dart';

abstract class RecipeIngredientRepository
    extends Repository<RecipeIngredientEntity, int> {
  Future<Either<Failure, int?>> findId(
      int recipeId, RecipeIngredient recipeIngredient);

  Future<Either<Failure, List<RecipeIngredientEntity>>> findByRecipe(
      int recipeId);

  Future<Either<Failure, void>> deleteByRecipe(int recipeId);
}
