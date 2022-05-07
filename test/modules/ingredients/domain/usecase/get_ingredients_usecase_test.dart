import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetIngredientsUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = IngredientRepositoryMock();
    usecase = GetIngredientsUseCase(repository);
  });

  test('WHEN called SHOULD get entities', () async {
    when(() => repository.findAllListing()).thenAnswer(
      (_) async => Right(listingIngredientDtoList),
    );

    final result = await usecase.execute(null);

    expect(result.getRight().toNullable(), listingIngredientDtoList);
    verify(() => repository.findAllListing());
  });

  test('WHEN called with IngredientsFilter SHOULD call repository with filter',
      () async {
    const filter = IngredientsFilter(name: 'Egg');
    when(() => repository.findAllListing(filter: filter)).thenAnswer(
      (_) async => Right(listingIngredientDtoList),
    );

    final result = await usecase.execute(filter);

    expect(result.getRight().toNullable(), listingIngredientDtoList);
    verify(() => repository.findAllListing(filter: filter));
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.findAllListing())
        .thenAnswer((_) async => Left(FakeFailure('error')));

    final result = await usecase.execute(null);

    expect(result.getLeft().toNullable()?.message, 'error');
    verify(() => repository.findAllListing());
  });
}
