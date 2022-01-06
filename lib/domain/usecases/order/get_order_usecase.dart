import 'package:fpdart/fpdart.dart' as fp;
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';

class GetOrderUseCase extends UseCase<int, Order?> {
  final OrderRepository repository;

  GetOrderUseCase(this.repository);

  @override
  Future<fp.Either<Failure, Order?>> execute(int id) {
    return repository.findById(id);
  }
}
