import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../clients.dart';

class GetAddressDomainUseCase extends UseCase<int, List<AddressDomainDto>> {
  final AddressRepository repository;

  GetAddressDomainUseCase(this.repository);

  @override
  Future<Either<Failure, List<AddressDomainDto>>> execute(int clientId) {
    return repository.findAllDomain(clientId);
  }
}
