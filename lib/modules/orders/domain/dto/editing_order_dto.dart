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
  final List<OrderProduct> products;
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
