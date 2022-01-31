import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_product.g.dart';

@JsonSerializable()
class OrderProduct extends Equatable {
  final int id;
  final double quantity;

  const OrderProduct({
    required this.id,
    required this.quantity,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) =>
      _$OrderProductFromJson(json);

  Map<String, dynamic> toJson() => _$OrderProductToJson(this);

  OrderProduct copyWith({
    int? id,
    double? quantity,
  }) {
    return OrderProduct(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, quantity];
}
