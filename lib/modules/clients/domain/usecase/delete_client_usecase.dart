import 'package:fpdart/fpdart.dart';

import '../repository/client_repository.dart';
import '../../../../core/core.dart';

class DeleteClientUseCase extends UseCase<int, void> {
  final ClientRepository repository;

  DeleteClientUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(int id) {
    return repository.deleteById(id);
  }
}
