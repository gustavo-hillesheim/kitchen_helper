import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/core.dart';
import '../../clients.dart';
import '../../../../database/database.dart';

part 'address_repository.g.dart';

abstract class AddressRepository extends Repository<AddressEntity, int> {
  Future<Either<Failure, List<AddressDomainDto>>> findAllDomain(int clientId);
}

@JsonSerializable()
class AddressEntity extends Equatable implements Entity<int> {
  @override
  final int? id;
  final int? clientId;
  final String identifier;
  final int? cep;
  final String? street;
  final int? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final States? state;

  const AddressEntity({
    required this.identifier,
    this.id,
    this.clientId,
    this.cep,
    this.street,
    this.number,
    this.complement,
    this.neighborhood,
    this.city,
    this.state,
  });

  AddressEntity.fromAddress(Address address, {this.clientId})
      : id = null,
        identifier = address.identifier,
        cep = address.cep,
        street = address.street,
        number = address.number,
        complement = address.complement,
        neighborhood = address.neighborhood,
        city = address.city,
        state = address.state;

  factory AddressEntity.fromJson(Map<String, dynamic> json) =>
      _$AddressEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AddressEntityToJson(this);

  Address toAddress() => Address(
        identifier: identifier,
        cep: cep,
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: state,
      );

  @override
  List<Object?> get props => [
        id,
        clientId,
        identifier,
        cep,
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
      ];
}
