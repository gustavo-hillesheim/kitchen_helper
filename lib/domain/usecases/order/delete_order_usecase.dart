import 'package:fpdart/fpdart.dart' as fp;

import '../../../core/core.dart';
import '../../domain.dart';

class DeleteOrderUseCase extends UseCase<Order, void> {
  static const cantDeleteOrderWithoutIdMessage =
      'Não é possível excluir um  registro que não foi salvo';

  final OrderRepository repository;

  DeleteOrderUseCase(this.repository);

  @override
  Future<fp.Either<Failure, void>> execute(Order order) async {
    if (order.id == null) {
      return const fp.Left(BusinessFailure(cantDeleteOrderWithoutIdMessage));
    }
    return repository.deleteById(order.id!);
  }
}
