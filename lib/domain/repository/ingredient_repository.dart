import '../../database/database.dart';
import '../models/ingredient.dart';

abstract class IngredientRepository extends Repository<Ingredient, int> {}
