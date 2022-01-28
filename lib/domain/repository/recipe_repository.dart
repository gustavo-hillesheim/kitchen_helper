import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';
import '../../database/database.dart';
import '../domain.dart';

abstract class RecipeRepository extends Repository<Recipe, int> {
  @override
  Future<Either<Failure, List<Recipe>>> findAll({RecipeFilter? filter});
  Future<Either<Failure, List<ListingRecipeDto>>> findAllListing();
}

class RecipeFilter extends Equatable {
  final bool? canBeSold;

  const RecipeFilter({this.canBeSold});

  @override
  List<Object?> get props => [canBeSold];
}
