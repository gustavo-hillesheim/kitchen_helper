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

  test(
    'WHEN the usecase is called with an ingredient without id '
    'THEN it should create a new register',
    () async {
      when(() => repository.create(any())).thenAnswer(
        (_) async => Right(sugarWithId.id!),
      );
      final result = await usecase.execute(sugarWithoutId);
      expect(result.isRight(), true);
      expect(result.getRight().toNullable()?.id, sugarWithId.id);
      verify(() => repository.create(sugarWithoutId));
      verifyNever(() => repository.update(any()));
    },
  );

  test(
    'WHEN the usecase is called with an ingredient with id that exists '
    'THEN it should update the register',
    () async {
      when(() => repository.exists(any()))
          .thenAnswer((_) async => const Right(true));
      when(() => repository.update(any()))
          .thenAnswer((_) async => const Right(null));
      final result = await usecase.execute(sugarWithId);
      expect(result.isRight(), true);
      expect(result.getRight().toNullable()?.id, sugarWithId.id);
      verify(() => repository.update(sugarWithId));
      verifyNever(() => repository.create(any()));
    },
  );

  test(
    'WHEN the usecase is called with an ingredient with id that doesn\'t '
    'exists THEN it should create the register',
    () async {
      when(() => repository.exists(any()))
          .thenAnswer((_) async => const Right(false));
      when(() => repository.create(any()))
          .thenAnswer((_) async => Right(sugarWithId.id!));
      final result = await usecase.execute(sugarWithId);
      expect(result.isRight(), true);
      expect(result.getRight().toNullable()?.id, sugarWithId.id);
      verify(() => repository.create(sugarWithId));
      verifyNever(() => repository.update(any()));
    },
  );

  test(
    'WHEN the repository returns a Failure on create '
    'THEN the usecase should return it too',
    () async {
      when(() => repository.create(any()))
          .thenAnswer((_) async => Left(FakeFailure('some error')));
      final result = await usecase.execute(sugarWithoutId);
      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'some error');
      verify(() => repository.create(sugarWithoutId));
      verifyNever(() => repository.update(any()));
    },
  );

  test(
    'WHEN the repository returns a Failure on update '
    'THEN the usecase should return it too',
    () async {
      when(() => repository.exists(any()))
          .thenAnswer((_) async => const Right(true));
      when(() => repository.update(any()))
          .thenAnswer((_) async => Left(FakeFailure('some error')));
      final result = await usecase.execute(sugarWithId);
      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'some error');
      verify(() => repository.update(sugarWithId));
      verifyNever(() => repository.create(any()));
    },
  );

  test(
    'WHEN the repository returns a Failure on exists '
    'THEN the usecase should return it too',
    () async {
      when(() => repository.exists(any()))
          .thenAnswer((_) async => Left(FakeFailure('some error')));
      final result = await usecase.execute(sugarWithId);
      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'some error');
      verify(() => repository.exists(any()));
      verifyNever(() => repository.create(any()));
      verifyNever(() => repository.update(any()));
    },
  );
}
