import 'package:json_annotation/json_annotation.dart';

import 'measurement_unit.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String? id;
  final String name;
  final double quantity;
  final MeasurementUnit measurementUnit;
  final double price;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.measurementUnit,
    required this.price,
    this.id,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
