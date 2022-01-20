import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_ingredient.g.dart';

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

extension RecipeIngredientTypeExtension on RecipeIngredientType {
  String? getName() {
    return _$RecipeIngredientTypeEnumMap[this];
  }
}
