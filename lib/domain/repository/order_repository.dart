import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' hide Order;

import '../../core/core.dart';
import '../../database/database.dart';
import '../models/models.dart';

abstract class OrderRepository implements Repository<Order, int> {
  @override
  Future<Either<Failure, List<Order>>> findAll({OrdersFilter? filter});
}

class OrdersFilter extends Equatable {
  final OrderStatus? status;

  const OrdersFilter({this.status});

  @override
  List<Object?> get props => [status];
}
