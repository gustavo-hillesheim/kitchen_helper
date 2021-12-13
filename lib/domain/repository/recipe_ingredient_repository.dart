import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/core.dart';
import '../domain.dart';

part 'recipe_ingredient_repository.g.dart';

abstract class RecipeIngredientRepository
    extends SQLiteRepository<RecipeIngredientEntity> {
  RecipeIngredientRepository(SQLiteDatabase database)
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
          toMap: (ri) => ri.toJson(),
        );

  Future<Either<Failure, int?>> findId(
      Recipe recipe, RecipeIngredient recipeIngredient) async {
    final result = await database.query(table: tableName, columns: [
      idColumn
    ], where: {
      'parentRecipeId': recipe.id,
      'recipeIngredientId': recipeIngredient.id,
      'type': _$RecipeIngredientTypeEnumMap[recipeIngredient.type],
    });
    if (result.isNotEmpty) {
      return Right(result[0]['id']);
    }
    return const Right(null);
  }
}

@JsonSerializable()
class RecipeIngredientEntity extends Equatable implements Entity<int> {
  @override
  final int? id;
  final int parentRecipeId;
  final int recipeIngredientId;
  final RecipeIngredientType type;

  const RecipeIngredientEntity({
    this.id,
    required this.parentRecipeId,
    required this.recipeIngredientId,
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
          type: recipeIngredient.type,
        );

  factory RecipeIngredientEntity.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientEntityToJson(this);

  RecipeIngredientEntity copyWith({
    int? id,
    int? parentRecipeId,
    int? recipeIngredientId,
    RecipeIngredientType? type,
  }) {
    return RecipeIngredientEntity(
      id: id ?? this.id,
      parentRecipeId: parentRecipeId ?? this.parentRecipeId,
      recipeIngredientId: recipeIngredientId ?? this.recipeIngredientId,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, parentRecipeId, recipeIngredientId, type];
}
