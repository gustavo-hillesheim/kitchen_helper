import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../domain.dart';

abstract class RecipeRepository extends Repository<Recipe, int> {
  @override
  Future<Either<Failure, List<Recipe>>> findAll({RecipesFilter? filter});

  Future<Either<Failure, List<ListingRecipeDto>>> findAllListing(
      {RecipesFilter? filter});

  Future<Either<Failure, List<RecipeDomainDto>>> findAllDomain(
      {RecipesFilter? filter});

  Future<Either<Failure, Set<int>>> getRecipesThatDependOn(int recipeId);

  Future<Either<Failure, double>> getCost(int recipeId, {double? quantity});
}

class RecipesFilter extends Equatable {
  final String? name;
  final bool? canBeSold;

  const RecipesFilter({this.name, this.canBeSold});

  @override
  List<Object?> get props => [name, canBeSold];
}
