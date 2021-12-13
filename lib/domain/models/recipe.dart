import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/core.dart';
import 'models.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe extends Equatable implements Entity<int> {
  @override
  final int? id;
  final String name;
  final String? notes;
  final double quantityProduced;
  final double? quantitySold;
  final double? price;
  final bool canBeSold;
  final MeasurementUnit measurementUnit;
  final List<RecipeIngredient> ingredients;

  const Recipe({
    this.id,
    required this.name,
    this.notes,
    required this.quantityProduced,
    this.quantitySold,
    this.price,
    required this.canBeSold,
    required this.measurementUnit,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);

  Recipe copyWith({
    int? id,
    String? name,
    String? notes,
    double? quantityProduced,
    double? quantitySold,
    double? price,
    bool? canBeSold,
    MeasurementUnit? measurementUnit,
    List<RecipeIngredient>? ingredients,
  }) {
    final copyIngredients = (ingredients ?? this.ingredients)
        .map<RecipeIngredient>((i) => i.copyWith())
        .toList(growable: false);

    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      quantityProduced: quantityProduced ?? this.quantityProduced,
      quantitySold: quantitySold ?? this.quantitySold,
      price: price ?? this.price,
      canBeSold: canBeSold ?? this.canBeSold,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      ingredients: copyIngredients,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        notes,
        quantityProduced,
        quantitySold,
        price,
        canBeSold,
        measurementUnit,
        ingredients
      ];
}

@JsonSerializable()
class RecipeIngredient extends Equatable {
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

enum RecipeIngredientType { ingredient, recipe }
