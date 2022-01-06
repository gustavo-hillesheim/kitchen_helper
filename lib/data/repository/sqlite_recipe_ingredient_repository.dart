import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';
import '../../domain/domain.dart';

class SQLiteRecipeIngredientRepository
    extends SQLiteRepository<RecipeIngredientEntity>
    implements RecipeIngredientRepository {
  SQLiteRecipeIngredientRepository(SQLiteDatabase database)
      : super(
          'recipeIngredients',
          'id',
          database,
          fromMap: (map) => RecipeIngredientEntity.fromJson(map),
          toMap: (ri) => ri.toJson(),
        );

  @override
  Future<Either<Failure, int?>> findId(
      int recipeId, RecipeIngredient recipeIngredient) async {
    try {
      final result = await database.query(table: tableName, columns: [
        idColumn
      ], where: {
        'parentRecipeId': recipeId,
        'recipeIngredientId': recipeIngredient.id,
        'type': recipeIngredient.type.getName(),
      });
      if (result.isNotEmpty) {
        return Right(result[0][idColumn]);
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteByRecipe(int recipeId) async {
    try {
      await database.delete(table: tableName, where: {
        'parentRecipeId': recipeId,
      });
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotDeleteMessage, e));
    }
  }

  @override
  Future<Either<Failure, List<RecipeIngredientEntity>>> findByRecipe(
      int recipeId) async {
    try {
      final queryResult = await database.query(
        table: tableName,
        columns: [
          'id',
          'parentRecipeId',
          'recipeIngredientId',
          'type',
          'quantity',
        ],
        where: {'parentRecipeId': recipeId},
      );
      final ingredientEntities =
          queryResult.map(fromMap).toList(growable: false);
      return Right(ingredientEntities);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }
}
