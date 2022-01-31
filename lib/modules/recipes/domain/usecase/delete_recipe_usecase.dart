import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../recipes.dart';

class DeleteRecipeUseCase extends UseCase<int, void> {
  final RecipeRepository repository;

  DeleteRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(int id) async {
    return repository.deleteById(id);
  }
}
