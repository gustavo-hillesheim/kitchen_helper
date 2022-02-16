import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../clients.dart';

class GetContactsDomainUseCase extends UseCase<int, List<ContactDomainDto>> {
  final ContactRepository repository;

  GetContactsDomainUseCase(this.repository);

  @override
  Future<Either<Failure, List<ContactDomainDto>>> execute(int clientId) {
    return repository.findAllDomain(clientId);
  }
}
