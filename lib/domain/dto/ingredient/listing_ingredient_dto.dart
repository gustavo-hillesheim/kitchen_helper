import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain.dart';

part 'listing_ingredient_dto.g.dart';

@JsonSerializable(createToJson: false)
class ListingIngredientDto extends Equatable {
  final int id;
  final String name;
  final double quantity;
  final MeasurementUnit measurementUnit;
  final double cost;

  const ListingIngredientDto({
    required this.id,
    required this.name,
    required this.quantity,
    required this.measurementUnit,
    required this.cost,
  });

  factory ListingIngredientDto.fromJson(Map<String, dynamic> json) =>
      _$ListingIngredientDtoFromJson(json);

  @override
  List<Object?> get props => [id, name, quantity, measurementUnit, cost];
}
