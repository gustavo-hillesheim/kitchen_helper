import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/repository/ingredient_repository.dart';
import 'package:kitchen_helper/domain/usecases/ingredient/get_ingredient_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late GetIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = MockIngredientRepository();
    usecase = GetIngredientUseCase(repository);
  });

  test('WHEN executed SHOULD return an ingredient', () async {
    when(() => repository.findById(sugarWithId.id!))
        .thenAnswer((_) async => Right(sugarWithId));

    final result = await usecase.execute(sugarWithId.id!);

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), sugarWithId);
    verify(() => repository.findById(sugarWithId.id!));
  });

  test(
    'WHEN repository returns a failure THEN usecase should return it too',
    () async {
      when(() => repository.findById(any()))
          .thenAnswer((_) async => Left(FakeFailure('error')));

      final result = await usecase.execute(123);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'error');
      verify(() => repository.findById(any()));
    },
  );
}
