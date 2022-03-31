import 'package:fpdart/fpdart.dart';

import '../../../../../core/core.dart';
import '../dto/listing_ingredient_dto.dart';
import '../repository/ingredient_repository.dart';

class GetIngredientsUseCase
    extends UseCase<IngredientsFilter?, List<ListingIngredientDto>> {
  final IngredientRepository repository;

  GetIngredientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListingIngredientDto>>> execute(
      IngredientsFilter? filter) {
    return repository.findAllListing(filter: filter);
  }
}
