import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../dto/listing_client_dto.dart';
import '../dto/client_domain_dto.dart';
import '../../../../../database/database.dart';
import '../model/client.dart';

abstract class ClientRepository extends Repository<Client, int> {
  Future<Either<Failure, List<ListingClientDto>>> findAllListing(
      {ClientsFilter? filter});

  Future<Either<Failure, List<ClientDomainDto>>> findAllDomain();
}

class ClientsFilter extends Equatable {
  final String? name;

  const ClientsFilter({this.name});

  @override
  List<Object?> get props => [name];
}
