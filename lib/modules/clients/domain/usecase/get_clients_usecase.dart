import 'package:fpdart/fpdart.dart';

import '../repository/client_repository.dart';
import '../../../../core/core.dart';
import '../dto/listing_client_dto.dart';

class GetClientsUseCase
    extends UseCase<ClientsFilter?, List<ListingClientDto>> {
  final ClientRepository repository;

  GetClientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListingClientDto>>> execute(
      ClientsFilter? filter) {
    return repository.findAllListing(filter: filter);
  }
}
