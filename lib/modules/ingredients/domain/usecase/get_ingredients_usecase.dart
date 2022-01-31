import 'package:fpdart/fpdart.dart';

import '../../../../../core/core.dart';
import '../dto/listing_ingredient_dto.dart';
import '../repository/ingredient_repository.dart';

class GetIngredientsUseCase
    extends UseCase<NoParams, List<ListingIngredientDto>> {
  final IngredientRepository repository;

  GetIngredientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListingIngredientDto>>> execute(NoParams input) {
    return repository.findAllListing();
  }
}
