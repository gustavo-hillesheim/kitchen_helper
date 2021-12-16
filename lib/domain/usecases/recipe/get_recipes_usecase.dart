import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class GetRecipesUseCase extends UseCase<NoParams, List<Recipe>> {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Recipe>>> execute(NoParams input) {
    return repository.findAll();
  }
}
