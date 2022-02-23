import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../dto/listing_client_dto.dart';
import '../dto/client_domain_dto.dart';
import '../../../../../database/database.dart';
import '../model/client.dart';

abstract class ClientRepository extends Repository<Client, int> {
  Future<Either<Failure, List<ListingClientDto>>> findAllListing();

  Future<Either<Failure, List<ClientDomainDto>>> findAllDomain();
}
