import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../database/database.dart';
import '../dto/ingredient/listing_ingredient_dto.dart';
import '../models/ingredient.dart';

abstract class IngredientRepository extends Repository<Ingredient, int> {
  Future<Either<Failure, List<ListingIngredientDto>>> findAllListing();
}
