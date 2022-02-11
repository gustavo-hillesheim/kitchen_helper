import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../clients.dart';
import '../../../../core/core.dart';
import '../../../../database/sqlite/sqlite.dart';

class SQLiteContactRepository extends SQLiteRepository<ContactEntity>
    implements ContactRepository {
  SQLiteContactRepository(SQLiteDatabase database)
      : super(
          'clientContacts',
          'id',
          database,
          toMap: (contact) => contact.toJson(),
          fromMap: (map) => ContactEntity.fromJson(map),
        );

  Future<Either<Failure, List<ContactEntity>>> findByClient(
      int clientId) async {
    try {
      final result = await database.query(
        table: tableName,
        columns: ['id', 'clientId', 'contact'],
        where: {'clientId': clientId},
      );
      return Right(result.map(ContactEntity.fromJson).toList());
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
