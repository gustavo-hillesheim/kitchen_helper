import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain.dart';

part 'listing_recipe_dto.g.dart';

@JsonSerializable(createToJson: false)
class ListingRecipeDto extends Equatable implements ListingDto {
  @override
  final int id;
  final String name;
  final double quantityProduced;
  final double? quantitySold;
  final double? price;
  final MeasurementUnit measurementUnit;

  const ListingRecipeDto({
    required this.id,
    required this.name,
    required this.quantityProduced,
    required this.measurementUnit,
    this.quantitySold,
    this.price,
  });

  factory ListingRecipeDto.fromJson(Map<String, dynamic> json) =>
      _$ListingRecipeDtoFromJson(json);

  @override
  List<Object?> get props =>
      [id, name, quantityProduced, quantitySold, price, measurementUnit];
}
