import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../domain.dart';

typedef RemoveRecipesThatDependOnResult
    = Future<Either<Failure, List<RecipeDomainDto>>> Function(
        List<RecipeDomainDto> domain);

class GetRecipesDomainUseCase
    extends UseCase<RecipeDomainFilter?, List<RecipeDomainDto>> {
  final RecipeRepository repository;

  GetRecipesDomainUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecipeDomainDto>>> execute(
    RecipeDomainFilter? filter,
  ) async {
    final domainResult = await repository.findAllDomain(
        filter: RecipeFilter(canBeSold: filter?.canBeSold));
    return domainResult
        .bindFuture(
            _removeRecipesThatDependOn(filter?.ignoreRecipesThatDependOn))
        .run();
  }

  RemoveRecipesThatDependOnResult _removeRecipesThatDependOn(int? recipe) {
    if (recipe == null) {
      return (domain) async => Right(domain);
    } else {
      return (domain) async {
        final recipesToRemoveResult =
            await repository.getRecipesThatDependOn(recipe);
        return recipesToRemoveResult.bind((recipesToRemove) {
          return Right(
            domain
                .where((d) => !recipesToRemove.contains(d.id) && d.id != recipe)
                .toList(),
          );
        });
      };
    }
  }
}

class RecipeDomainFilter extends Equatable {
  final bool? canBeSold;
  final int? ignoreRecipesThatDependOn;

  const RecipeDomainFilter({this.canBeSold, this.ignoreRecipesThatDependOn});

  @override
  List<Object?> get props => [canBeSold, ignoreRecipesThatDependOn];
}
