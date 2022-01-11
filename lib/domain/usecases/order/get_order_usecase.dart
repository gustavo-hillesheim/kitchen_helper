import 'package:fpdart/fpdart.dart' as fp;

import '../../../core/core.dart';
import '../../domain.dart';

class GetOrderUseCase extends UseCase<int, Order?> {
  final OrderRepository repository;

  GetOrderUseCase(this.repository);

  @override
  Future<fp.Either<Failure, Order?>> execute(int id) {
    return repository.findById(id);
  }
}
