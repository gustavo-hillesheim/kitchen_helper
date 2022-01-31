import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../database/database.dart';
import '../../../../common/common.dart';

part 'ingredient.g.dart';

@JsonSerializable()
class Ingredient extends Equatable implements Entity<int> {
  @override
  final int? id;
  final String name;
  final double quantity;
  final MeasurementUnit measurementUnit;
  final double cost;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.measurementUnit,
    required this.cost,
    this.id,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) =>
      _$IngredientFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientToJson(this);

  copyWith({
    int? id,
    String? name,
    double? quantity,
    MeasurementUnit? measurementUnit,
    double? cost,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      cost: cost ?? this.cost,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, measurementUnit, cost];
}
