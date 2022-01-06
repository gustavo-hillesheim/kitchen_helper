import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../database/database.dart';
import 'recipe.dart';

part 'recipe_ingredient.g.dart';

@JsonSerializable()
class RecipeIngredient extends Equatable implements Entity<int> {
  @override
  final int id;
  final double quantity;
  final RecipeIngredientType type;

  const RecipeIngredient({
    required this.id,
    required this.quantity,
    required this.type,
  });

  const RecipeIngredient.ingredient(
    int id, {
    required double quantity,
  }) : this(id: id, quantity: quantity, type: RecipeIngredientType.ingredient);

  const RecipeIngredient.recipe(
    int id, {
    required double quantity,
  }) : this(id: id, quantity: quantity, type: RecipeIngredientType.recipe);

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$RecipeIngredientFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeIngredientToJson(this);

  RecipeIngredient copyWith({
    int? id,
    double? quantity,
    RecipeIngredientType? type,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, quantity, type];
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

  RecipeIngredientEntity copyWith({
    int? id,
    int? parentRecipeId,
    int? recipeIngredientId,
    double? quantity,
    RecipeIngredientType? type,
  }) {
    return RecipeIngredientEntity(
      id: id ?? this.id,
      parentRecipeId: parentRecipeId ?? this.parentRecipeId,
      recipeIngredientId: recipeIngredientId ?? this.recipeIngredientId,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props =>
      [id, parentRecipeId, recipeIngredientId, quantity, type];
}

enum RecipeIngredientType { ingredient, recipe }

extension RecipeIngredientTypeExtension on RecipeIngredientType {
  String? getName() {
    return _$RecipeIngredientTypeEnumMap[this];
  }
}
