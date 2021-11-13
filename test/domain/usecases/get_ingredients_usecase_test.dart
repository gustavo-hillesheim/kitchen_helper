import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/usecase.dart';
import 'package:kitchen_helper/domain/data/ingredient_repository.dart';
import 'package:kitchen_helper/domain/usecases/get_ingredients_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late GetIngredientsUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = MockIngredientRepository();
    usecase = GetIngredientsUseCase(repository);
  });

  test('WHEN executed SHOULD return list of ingredients', () async {
    when(() => repository.findAll())
        .thenAnswer((_) async => Right(ingredientList));
    final result = await usecase.execute(const NoParams());

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), ingredientList);
    verify(() => repository.findAll());
  });

  test(
    'WHEN the repository returns a Failure THEN usecase should return it too',
    () async {
      when(() => repository.findAll())
          .thenAnswer((_) async => Left(FakeFailure('another error')));
      final result = await usecase.execute(const NoParams());

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'another error');
      verify(() => repository.findAll());
    },
  );
}
