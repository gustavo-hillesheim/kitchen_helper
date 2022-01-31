import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failure.dart';
import '../../../../database/sqlite/sqlite.dart';
import '../../domain/dto/listing_client_dto.dart';
import '../../domain/model/client.dart';
import '../../domain/repository/client_repository.dart';

class SQLiteClientRepository extends SQLiteRepository<Client>
    implements ClientRepository {
  SQLiteClientRepository(SQLiteDatabase database)
      : super(
          'clients',
          'id',
          database,
          fromMap: (map) {
            map = Map.from(map);
            map['addresses'] = [];
            map['contacts'] = [];
            return Client.fromJson(map);
          },
          toMap: (client) {
            final map = client.toJson();
            map.remove('addresses');
            map.remove('contacts');
            return map;
          },
        );

  @override
  Future<Either<Failure, List<ListingClientDto>>> findAllListing() async {
    try {
      final result = await database.query(
        table: tableName,
        columns: ['id', 'name'],
      );
      return Right(result.map(ListingClientDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }
}
