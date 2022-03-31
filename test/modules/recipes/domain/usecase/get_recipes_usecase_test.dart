import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetRecipesUseCase usecase;
  late RecipeRepository repository;

  setUp(() {
    repository = RecipeRepositoryMock();
    usecase = GetRecipesUseCase(repository);
  });

  test('WHEN called SHOULD get entities', () async {
    when(() => repository.findAllListing()).thenAnswer(
      (_) async => Right([listingCakeRecipeDto, listingIceCreamRecipeDto]),
    );

    final result = await usecase.execute();

    expect(result.getRight().toNullable(),
        [listingCakeRecipeDto, listingIceCreamRecipeDto]);
    verify(() => repository.findAllListing());
  });

  test('WHEN filter is provided SHOULD call repository with filter', () async {
    const filter = RecipesFilter(name: 'Cake', canBeSold: true);

    when(() => repository.findAllListing(filter: filter)).thenAnswer(
      (_) async => Right([listingCakeRecipeDto, listingIceCreamRecipeDto]),
    );

    final result = await usecase.execute(filter);

    expect(result.getRight().toNullable(),
        [listingCakeRecipeDto, listingIceCreamRecipeDto]);
    verify(() => repository.findAllListing(filter: filter));
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.findAllListing())
        .thenAnswer((_) async => Left(FakeFailure('error')));

    final result = await usecase.execute();

    expect(result.getLeft().toNullable()?.message, 'error');
    verify(() => repository.findAllListing());
  });
}
