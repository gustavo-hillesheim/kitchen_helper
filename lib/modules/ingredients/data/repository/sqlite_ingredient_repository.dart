import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/database/sqlite/query_operators.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/failure.dart';
import '../../../../database/sqlite/sqlite.dart';
import '../../ingredients.dart';

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
  Future<Either<Failure, List<ListingIngredientDto>>> findAllListing(
      {IngredientsFilter? filter}) async {
    try {
      final records = await database.query(
        table: tableName,
        columns: ['id', 'name', 'measurementUnit', 'quantity', 'cost'],
        orderBy: 'name COLLATE NOCASE',
        where: filter?.asWhereMap(),
      );
      return Right(records.map(ListingIngredientDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }
}

extension on IngredientsFilter {
  Map<String, dynamic> asWhereMap() {
    final result = <String, dynamic>{};
    if (name != null) {
      result['name'] = Contains(name!);
    }
    return result;
  }
}
