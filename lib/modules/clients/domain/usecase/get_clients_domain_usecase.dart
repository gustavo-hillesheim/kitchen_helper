import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../clients.dart';

class GetClientsDomainUseCase extends UseCase<NoParams, List<ClientDomainDto>> {
  final ClientRepository repository;

  GetClientsDomainUseCase(this.repository);

  @override
  Future<Either<Failure, List<ClientDomainDto>>> execute(NoParams input) {
    return repository.findAllDomain();
  }
}
