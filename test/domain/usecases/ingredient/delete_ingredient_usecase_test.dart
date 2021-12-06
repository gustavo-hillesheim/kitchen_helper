import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late DeleteIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    repository = IngredientRepositoryMock();
    usecase = DeleteIngredientUseCase(repository);
  });

  test('WHEN executed SHOULD delete the ingredient', () async {
    when(() => repository.deleteById(sugarWithId.id!))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(sugarWithId);

    expect(result.isRight(), true);
    verify(() => repository.deleteById(sugarWithId.id!));
  });

  test(
    'WHEN repository returns a failure THEN usecase should return it too',
    () async {
      when(() => repository.deleteById(sugarWithId.id!))
          .thenAnswer((_) async => Left(FakeFailure('Delete error')));

      final result = await usecase.execute(sugarWithId);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'Delete error');
      verify(() => repository.deleteById(sugarWithId.id!));
    },
  );

  test(
    'WHEN deleting an ingredient without id SHOULD return Failure',
    () async {
      final result = await usecase.execute(sugarWithoutId);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message,
          DeleteIngredientUseCase.cantDeleteIngredientWithoutIdMessage);
    },
  );
}
