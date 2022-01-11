import 'package:fpdart/fpdart.dart' as fp;

import '../../../core/core.dart';
import '../../domain.dart';

class GetOrdersUseCase extends UseCase<NoParams, List<Order>> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<fp.Either<Failure, List<Order>>> execute(NoParams _) {
    return repository.findAll();
  }
}
