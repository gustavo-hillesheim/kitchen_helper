import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/model/address.dart';
import '../../domain/model/states.dart';
import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../../../../database/sqlite/sqlite.dart';

part 'sqlite_address_repository.g.dart';

class SQLiteAddressRepository extends SQLiteRepository<AddressEntity> {
  SQLiteAddressRepository(SQLiteDatabase database)
      : super(
          'clientAddresses',
          'id',
          database,
          toMap: (contact) => contact.toJson(),
          fromMap: (map) => AddressEntity.fromJson(map),
        );

  Future<Either<Failure, List<AddressEntity>>> findByClient(
      int clientId) async {
    try {
      final result = await database.query(
        table: tableName,
        columns: [
          'id',
          'clientId',
          'identifier',
          'cep',
          'street',
          'number',
          'complement',
          'neighborhood',
          'city',
          'state',
        ],
        where: {'clientId': clientId},
      );
      return Right(result.map(AddressEntity.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  Future<Either<Failure, void>> deleteByClient(int clientId) async {
    try {
      await database.delete(table: tableName, where: {'clientId': clientId});
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotDeleteMessage, e));
    }
  }
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
