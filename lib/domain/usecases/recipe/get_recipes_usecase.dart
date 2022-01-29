import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class GetRecipesUseCase extends UseCase<NoParams, List<ListingRecipeDto>> {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ListingRecipeDto>>> execute(NoParams input) {
    return repository.findAllListing();
  }
}
