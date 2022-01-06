import 'package:fpdart/fpdart.dart' as fp;
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';

class GetOrdersUseCase extends UseCase<NoParams, List<Order>> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<fp.Either<Failure, List<Order>>> execute(NoParams _) {
    return repository.findAll();
  }
}
