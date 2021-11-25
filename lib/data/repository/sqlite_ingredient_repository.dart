import 'package:kitchen_helper/core/sqlite/sqlite_database.dart';
import 'package:kitchen_helper/core/sqlite/sqlite_repository.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/repository/ingredient_repository.dart';

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
}
