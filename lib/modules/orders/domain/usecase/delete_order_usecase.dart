import 'package:fpdart/fpdart.dart' as fp;

import '../../../../core/core.dart';
import '../domain.dart';

class DeleteOrderUseCase extends UseCase<int, void> {
  final OrderRepository repository;

  DeleteOrderUseCase(this.repository);

  @override
  Future<fp.Either<Failure, void>> execute(int id) async {
    return repository.deleteById(id);
  }
}
