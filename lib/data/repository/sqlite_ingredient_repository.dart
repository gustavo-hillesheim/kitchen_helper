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
}
