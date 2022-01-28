import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

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

    final result = await usecase.execute(const NoParams());

    expect(result.getRight().toNullable(), listingIngredientDtoList);
    verify(() => repository.findAllListing());
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    when(() => repository.findAllListing())
        .thenAnswer((_) async => const Left(FakeFailure('error')));

    final result = await usecase.execute(const NoParams());

    expect(result.getLeft().toNullable()?.message, 'error');
    verify(() => repository.findAllListing());
  });
}
