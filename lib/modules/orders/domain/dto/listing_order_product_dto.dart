import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../common/common.dart';

part 'listing_order_product_dto.g.dart';

@JsonSerializable(createToJson: false)
class ListingOrderProductDto extends Equatable {
  final double quantity;
  final MeasurementUnit measurementUnit;
  final String name;

  const ListingOrderProductDto({
    required this.quantity,
    required this.measurementUnit,
    required this.name,
  });

  factory ListingOrderProductDto.fromJson(Map<String, dynamic> json) =>
      _$ListingOrderProductDtoFromJson(json);

  @override
  List<Object?> get props => [quantity, name, measurementUnit];
}
