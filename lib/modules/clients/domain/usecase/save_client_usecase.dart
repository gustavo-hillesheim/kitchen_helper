import 'package:fpdart/fpdart.dart';

import '../repository/client_repository.dart';
import '../../../../core/core.dart';
import '../model/client.dart';

class SaveClientUseCase extends UseCase<Client, Client> {
  final ClientRepository repository;

  SaveClientUseCase(this.repository);

  @override
  Future<Either<Failure, Client>> execute(Client client) async {
    final result = await repository.save(client);
    return result.map((id) => client.copyWith(id: id));
  }
}
