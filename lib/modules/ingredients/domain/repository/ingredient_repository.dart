import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../dto/listing_ingredient_dto.dart';
import '../model/ingredient.dart';

abstract class IngredientRepository extends Repository<Ingredient, int> {
  Future<Either<Failure, List<ListingIngredientDto>>> findAllListing(
      {IngredientsFilter? filter});
}

class IngredientsFilter extends Equatable {
  final String? name;

  const IngredientsFilter({this.name});

  @override
  List<Object?> get props => [name];
}
