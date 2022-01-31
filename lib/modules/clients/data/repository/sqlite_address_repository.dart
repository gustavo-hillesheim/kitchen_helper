import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:kitchen_helper/modules/clients/domain/model/address.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../../../../database/sqlite/sqlite.dart';

part 'sqlite_address_repository.g.dart';

class SQLiteAddressRepository extends SQLiteRepository<AddressEntity> {
  SQLiteAddressRepository(SQLiteDatabase database)
      : super(
          'clientAddressess',
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
  final int cep;
  final String street;
  final int number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String state;

  const AddressEntity({
    this.id,
    this.clientId,
    required this.cep,
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  AddressEntity.fromAddress(Address address, {this.clientId})
      : id = null,
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
        cep,
        street,
        number,
        complement,
        neighborhood,
        city,
        state,
      ];
}
