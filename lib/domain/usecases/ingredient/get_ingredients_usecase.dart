import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';

import '../../../core/core.dart';

class GetIngredientsUseCase
    extends UseCase<NoParams, List<ListingIngredientDto>> {
  final IngredientRepository repository;

  GetIngredientsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListingIngredientDto>>> execute(NoParams input) {
    return repository.findAllListing();
  }
}
