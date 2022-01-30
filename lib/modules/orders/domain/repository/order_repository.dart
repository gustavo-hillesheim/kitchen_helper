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
}

class OrdersFilter extends Equatable {
  final OrderStatus? status;

  const OrdersFilter({this.status});

  @override
  List<Object?> get props => [status];
}
