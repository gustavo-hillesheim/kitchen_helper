import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/domain/data/ingredient_repository.dart';
import 'package:kitchen_helper/domain/usecases/save_ingredient_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late SaveIngredientUseCase usecase;
  late IngredientRepository repository;

  setUp(() {
    registerFallbackValue(FakeIngredient());

    repository = MockIngredientRepository();
    usecase = SaveIngredientUseCase(repository);
  });

  test(
    'WHEN the usecase is called with an ingredient without id '
    'THEN it should create a new register',
    () async {
      when(() => repository.create(any())).thenAnswer(
        (_) async => Either.right(sugarWithId.id!),
      );
      final result = await usecase.execute(sugarWithoutId);
      expect(result.isRight(), true);
      expect(result.getRight().toNullable()?.id, sugarWithId.id);
      verify(() => repository.create(sugarWithoutId));
    },
  );

  test(
    'WHEN the usecase is called with an ingredient with id '
    'THEN it should update the register',
    () async {
      when(() => repository.update(any()))
          .thenAnswer((_) async => Either.right(sugarWithId));
      final result = await usecase.execute(sugarWithId);
      expect(result.isRight(), true);
      expect(result.getRight().toNullable()?.id, sugarWithId.id);
      verify(() => repository.update(sugarWithId));
    },
  );

  test(
    'WHEN the repository returns a Failure on create '
    'THEN the usecase should return it too',
    () async {
      when(() => repository.create(any()))
          .thenAnswer((_) async => Either.left(FakeFailure('some error')));
      final result = await usecase.execute(sugarWithoutId);
      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'some error');
      verify(() => repository.create(sugarWithoutId));
    },
  );

  test(
    'WHEN the repository returns a Failure on update '
    'THEN the usecase should return it too',
    () async {
      when(() => repository.update(any()))
          .thenAnswer((_) async => Either.left(FakeFailure('some error')));
      final result = await usecase.execute(sugarWithId);
      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'some error');
      verify(() => repository.update(sugarWithId));
    },
  );
}
