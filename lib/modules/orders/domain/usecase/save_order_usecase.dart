import 'package:fpdart/fpdart.dart' as fp;

import '../../../../core/core.dart';
import '../../../../extensions.dart';
import '../domain.dart';

class SaveOrderUseCase extends UseCase<Order, Order> {
  final OrderRepository repository;

  SaveOrderUseCase(this.repository);

  @override
  Future<fp.Either<Failure, Order>> execute(Order order) {
    return repository
        .save(order)
        .onRightThen((id) => fp.Right(order.copyWith(id: id)));
  }
}
