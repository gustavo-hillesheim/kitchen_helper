import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../domain/domain.dart';

class SQLiteRecipeIngredientRepository
    extends SQLiteRepository<RecipeIngredientEntity>
    implements RecipeIngredientRepository {
  SQLiteRecipeIngredientRepository(SQLiteDatabase database)
      : super(
          'recipe_ingredients',
          'id',
          database,
          fromMap: (map) {
            // This is necessary since SQFLite doesn't support boolean types
            map['canBeSold'] = map['canBeSold'] == 1;
            return RecipeIngredientEntity.fromJson(map);
          },
          toMap: (ri) {
            final map = ri.toJson();
            map['canBeSold'] = map['canBeSold'] == true ? 1 : 0;
            return map;
          },
        );

  @override
  Future<Either<Failure, int?>> findId(
      Recipe recipe, RecipeIngredient recipeIngredient) async {
    final result = await database.query(table: tableName, columns: [
      idColumn
    ], where: {
      'parentRecipeId': recipe.id,
      'recipeIngredientId': recipeIngredient.id,
      'type': recipeIngredient.type.getName(),
    });
    if (result.isNotEmpty) {
      return Right(result[0][idColumn]);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteByRecipe(int recipeId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<RecipeIngredientEntity>>> findByRecipe(
      int recipeId) {
    throw UnimplementedError();
  }
}
