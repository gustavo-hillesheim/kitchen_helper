import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain.dart';

part 'editing_order_dto.g.dart';

@JsonSerializable()
class EditingOrderDto extends Equatable {
  final int? id;
  final int? clientId;
  final String? clientName;
  final int? contactId;
  final String? clientContact;
  final int? addressId;
  final String? clientAddress;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final List<EditingOrderProductDto> products;
  final List<Discount> discounts;

  const EditingOrderDto({
    this.id,
    required this.clientId,
    required this.clientName,
    required this.contactId,
    required this.clientContact,
    required this.clientAddress,
    required this.addressId,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    required this.products,
    required this.discounts,
  });

  factory EditingOrderDto.fromJson(Map<String, dynamic> json) =>
      _$EditingOrderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EditingOrderDtoToJson(this);

  EditingOrderDto copyWith({
    int? id,
    int? clientId,
    String? client,
    int? contactId,
    String? contact,
    int? addressId,
    String? address,
    DateTime? orderDate,
    DateTime? deliveryDate,
    OrderStatus? status,
    List<EditingOrderProductDto>? products,
    List<Discount>? discounts,
  }) {
    return EditingOrderDto(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: client ?? this.clientName,
      contactId: contactId ?? this.contactId,
      clientContact: contact ?? this.clientContact,
      clientAddress: address ?? this.clientAddress,
      addressId: addressId ?? this.addressId,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      products: products ?? this.products,
      discounts: discounts ?? this.discounts,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        clientName,
        contactId,
        clientContact,
        addressId,
        clientAddress,
        orderDate,
        deliveryDate,
        status,
        products,
        discounts,
      ];
}
