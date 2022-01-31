import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../dto/listing_ingredient_dto.dart';
import '../model/ingredient.dart';

abstract class IngredientRepository extends Repository<Ingredient, int> {
  Future<Either<Failure, List<ListingIngredientDto>>> findAllListing();
}
