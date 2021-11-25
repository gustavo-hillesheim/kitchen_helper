import '../../core/sqlite/sqlite_database.dart';
import '../../core/sqlite/sqlite_repository.dart';
import '../../domain/models/ingredient.dart';
import '../../domain/repository/ingredient_repository.dart';

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
