import 'package:fpdart/fpdart.dart';

import '../../../core/core.dart';
import '../../domain.dart';

class DeleteRecipeUseCase extends UseCase<Recipe, void> {
  static const cantDeleteRecipeWithoutIdMessage =
      'Não é possível excluir um  registro que não foi salvo';

  final RecipeRepository repository;

  DeleteRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(Recipe recipe) async {
    if (recipe.id == null) {
      return const Left(BusinessFailure(cantDeleteRecipeWithoutIdMessage));
    }
    return repository.deleteById(recipe.id!);
  }
}
