import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/failure.dart';
import '../../database/sqlite/sqlite.dart';
import '../../domain/domain.dart';

class SQLiteIngredientRepository extends SQLiteRepository<Ingredient>
    implements IngredientRepository {
  SQLiteIngredientRepository(SQLiteDatabase database)
      : super(
          'ingredients',
          'id',
          database,
          fromMap: (map) => Ingredient.fromJson(map),
          toMap: (ingredient) => ingredient.toJson(),
        );

  @override
  Future<Either<Failure, List<ListingIngredientDto>>> findAllListing() async {
    try {
      final records = await database.query(
        table: tableName,
        columns: ['id', 'name', 'measurementUnit', 'quantity', 'cost'],
        orderBy: 'name',
      );
      return Right(records.map(ListingIngredientDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return const Left(
          RepositoryFailure(SQLiteRepository.couldNotFindAllMessage));
    }
  }
}
