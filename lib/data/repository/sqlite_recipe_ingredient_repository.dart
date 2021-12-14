import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';

class SQLiteRecipeIngredientRepository
    extends SQLiteRepository<RecipeIngredientEntity> {
  SQLiteRecipeIngredientRepository(SQLiteDatabase database)
      : super(
          'recipe_ingredients',
          'id',
          database,
          fromMap: (map) {
            // This is necessary since SQFLite doesn't support boolean types
            if (map.containsKey('canBeSold')) {
              map['canBeSold'] = map['canBeSold'] == 1;
            }
            return RecipeIngredientEntity.fromJson(map);
          },
          toMap: (ri) {
            final map = ri.toJson();
            if (map.containsKey('canBeSold')) {
              map['canBeSold'] = map['canBeSold'] == true ? 1 : 0;
            }
            return map;
          },
        );

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
}
