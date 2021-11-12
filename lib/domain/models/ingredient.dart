import 'package:json_annotation/json_annotation.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient {
  final String name;
  final double quantity;
  final MeasurementUnit measurementUnit;
  final double price;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.measurementUnit,
    required this.price,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}
