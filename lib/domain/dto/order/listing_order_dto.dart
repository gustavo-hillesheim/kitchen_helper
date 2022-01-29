import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain.dart';

part 'listing_order_dto.g.dart';

@JsonSerializable(createToJson: false)
class ListingOrderDto extends Equatable implements ListingDto {
  @override
  final int id;
  final String clientName;
  final String clientAddress;
  final DateTime deliveryDate;
  final double price;
  final OrderStatus status;

  const ListingOrderDto({
    required this.id,
    required this.clientName,
    required this.clientAddress,
    required this.deliveryDate,
    required this.price,
    required this.status,
  });

  factory ListingOrderDto.fromJson(Map<String, dynamic> json) =>
      _$ListingOrderDtoFromJson(json);

  @override
  List<Object?> get props => [
        id,
        clientName,
        clientAddress,
        deliveryDate,
        price,
      ];
}
