import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../domain.dart';

abstract class OrderRepository implements Repository<Order, int> {
  @override
  Future<Either<Failure, List<Order>>> findAll({OrdersFilter? filter});

  Future<Either<Failure, List<ListingOrderDto>>> findAllListing(
      {OrdersFilter? filter});

  Future<Either<Failure, List<ListingOrderProductDto>>>
      findAllOrderProductsListing(int orderId);

  Future<Either<Failure, EditingOrderDto?>> findEditingDtoById(int id);
}

class OrdersFilter extends Equatable {
  final int? clientId;
  final DateTime? orderDateStart;
  final DateTime? orderDateEnd;
  final DateTime? deliveryDateStart;
  final DateTime? deliveryDateEnd;
  final OrderStatus? status;

  const OrdersFilter({
    this.status,
    this.clientId,
    this.orderDateStart,
    this.orderDateEnd,
    this.deliveryDateStart,
    this.deliveryDateEnd,
  });

  @override
  List<Object?> get props => [
        status,
        clientId,
        orderDateStart,
        orderDateEnd,
        deliveryDateStart,
        deliveryDateEnd,
      ];
}
