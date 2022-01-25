import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../database/database.dart';
import 'models.dart';

part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order extends Equatable implements Entity<int> {
  @override
  final int? id;
  final String clientName;
  final String clientAddress;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final OrderStatus status;
  final List<OrderProduct> products;
  final List<Discount> discounts;

  const Order({
    this.id,
    required this.clientName,
    required this.clientAddress,
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
      clientName: clientName ?? this.clientName,
      clientAddress: clientAddress ?? this.clientAddress,
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
        clientName,
        clientAddress,
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
