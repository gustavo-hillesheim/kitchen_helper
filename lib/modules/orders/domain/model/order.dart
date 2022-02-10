import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../database/database.dart';
import '../domain.dart';

part 'order.g.dart';

@JsonSerializable()
class Order extends Equatable implements Entity<int> {
  @override
  final int? id;
  final int clientId;
  final int? contactId;
  final int? addressId;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final List<OrderProduct> products;
  final List<Discount> discounts;

  const Order({
    this.id,
    required this.clientId,
    required this.contactId,
    required this.addressId,
    required this.orderDate,
    required this.deliveryDate,
    required this.status,
    required this.products,
    required this.discounts,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    int? id,
    int? clientId,
    int? contactId,
    int? addressId,
    String? clientName,
    String? clientAddress,
    DateTime? orderDate,
    DateTime? deliveryDate,
    OrderStatus? status,
    List<OrderProduct>? products,
    List<Discount>? discounts,
  }) {
    return Order(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      contactId: contactId ?? this.contactId,
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
        contactId,
        addressId,
        orderDate,
        deliveryDate,
        status,
        products,
        discounts,
      ];
}

enum OrderStatus { ordered, delivered }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.ordered:
        return 'Recebido';
      case OrderStatus.delivered:
        return 'Entregue';
    }
  }
}
