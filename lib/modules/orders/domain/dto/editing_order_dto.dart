import 'package:equatable/equatable.dart';

import '../domain.dart';

class EditingOrderDto extends Equatable {
  final int? id;
  final int? clientId;
  final String? client;
  final int? contactId;
  final String? contact;
  final int? addressId;
  final String? address;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final List<EditingOrderProductDto> products;
  final List<Discount> discounts;

  const EditingOrderDto({
    this.id,
    required this.clientId,
    required this.client,
    required this.contactId,
    required this.contact,
    required this.address,
    required this.addressId,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    required this.products,
    required this.discounts,
  });

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
      client: client ?? this.client,
      contactId: contactId ?? this.contactId,
      contact: contact ?? this.contact,
      address: address ?? this.address,
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
        client,
        contactId,
        contact,
        addressId,
        address,
        orderDate,
        deliveryDate,
        status,
        products,
        discounts,
      ];
}
