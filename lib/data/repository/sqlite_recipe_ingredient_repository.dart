import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';
import '../../database/database.dart';
import '../../database/sqlite/sqlite.dart';
import '../../domain/domain.dart';

part 'sqlite_recipe_ingredient_repository.g.dart';

abstract class RecipeIngredientRepository
    extends Repository<RecipeIngredientEntity, int> {
  Future<Either<Failure, int?>> findId(
      int recipeId, RecipeIngredient recipeIngredient);

  Future<Either<Failure, List<RecipeIngredientEntity>>> findByRecipe(
      int recipeId);

  Future<Either<Failure, void>> deleteByRecipe(int recipeId);
}

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

@JsonSerializable()
class RecipeIngredientEntity extends Equatable implements Entity<int> {
  @override
  final int? id;
  final int parentRecipeId;
  final int recipeIngredientId;
  final double quantity;
  final RecipeIngredientType type;

  const RecipeIngredientEntity({
    this.id,
    required this.parentRecipeId,
    required this.recipeIngredientId,
    required this.quantity,
    required this.type,
  });

  RecipeIngredientEntity.fromModels(
    Recipe recipe,
    RecipeIngredient recipeIngredient, {
    int? id,
  }) : this(
          id: id,
          parentRecipeId: recipe.id!,
          recipeIngredientId: recipeIngredient.id,
          quantity: recipeIngredient.quantity,
          type: recipeIngredient.type,
        );

  factory RecipeIngredientEntity.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientEntityToJson(this);

  RecipeIngredient toRecipeIngredient() => RecipeIngredient(
        id: recipeIngredientId,
        type: type,
        quantity: quantity,
      );

  @override
  List<Object?> get props =>
      [id, parentRecipeId, recipeIngredientId, quantity, type];
}
