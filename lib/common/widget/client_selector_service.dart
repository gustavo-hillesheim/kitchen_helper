import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../modules/clients/clients.dart';

class ClientSelectorService {
  final GetClientsDomainUseCase getClientsDomainUseCase;

  ClientSelectorService(this.getClientsDomainUseCase);

  Future<Either<Failure, List<ClientDomainDto>>> findClientsDomain() {
    return getClientsDomainUseCase.execute(const NoParams());
  }
}
