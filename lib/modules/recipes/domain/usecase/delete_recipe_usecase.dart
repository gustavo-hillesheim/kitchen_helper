import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../domain/domain.dart';

class DeleteRecipeUseCase extends UseCase<int, void> {
  static const cantDeleteRecipeWithoutIdMessage =
      'Não é possível excluir um  registro que não foi salvo';

  final RecipeRepository repository;

  DeleteRecipeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> execute(int id) async {
    return repository.deleteById(id);
  }
}
