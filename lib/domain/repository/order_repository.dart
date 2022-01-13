import 'package:fpdart/fpdart.dart' hide Order;

import '../../core/core.dart';
import '../../database/database.dart';
import '../models/models.dart';

abstract class OrderRepository implements Repository<Order, int> {
  @override
  Future<Either<Failure, List<Order>>> findAll({OrdersFilter? filter});
}

class OrdersFilter {
  final OrderStatus? status;

  OrdersFilter({this.status});
}
