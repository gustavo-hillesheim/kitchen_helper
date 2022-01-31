import 'package:fpdart/fpdart.dart';

import '../repository/client_repository.dart';
import '../../../../core/core.dart';
import '../model/client.dart';

class GetClientUseCase extends UseCase<int, Client?> {
  final ClientRepository repository;

  GetClientUseCase(this.repository);

  @override
  Future<Either<Failure, Client?>> execute(int id) {
    return repository.findById(id);
  }
}
