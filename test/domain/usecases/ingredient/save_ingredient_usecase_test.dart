import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late SaveIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    registerFallbackValue(FakeIngredient());

    repository = IngredientRepositoryMock();
    usecase = SaveIngredientUseCase(repository);
  });

  test('WHEN executed SHOULD save ingredient in repository', () async {
    when(() => repository.save(any()))
        .thenAnswer((_) async => Right(sugarWithId.id!));

    final result = await usecase.execute(sugarWithoutId);

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), sugarWithId);
    verify(() => repository.save(sugarWithoutId));
  });

  test(
    'WHEN the repository returns a Failure THEN usecase should return it too',
    () async {
      when(() => repository.save(any()))
          .thenAnswer((_) async => Left(FakeFailure('error')));
      final result = await usecase.execute(sugarWithoutId);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'error');
      verify(() => repository.save(sugarWithoutId));
    },
  );
}
