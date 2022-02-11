import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/repository/address_repository.dart';
import '../../../../core/core.dart';
import '../../../../database/sqlite/sqlite.dart';

class SQLiteAddressRepository extends SQLiteRepository<AddressEntity>
    implements AddressRepository {
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
