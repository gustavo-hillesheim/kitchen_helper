import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/database.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void saveUseCaseTests<T extends Entity<ID>, ID>({
  required UseCase<T, T> Function() usecaseFn,
  required Repository<T, ID> Function() repositoryFn,
  required T entityWithId,
  required T entityWithoutId,
  required ID id,
}) {
  test('WHEN executed SHOULD save the entity in the repository', () async {
    final repository = repositoryFn();
    final usecase = usecaseFn();
    when(() => repository.save(any())).thenAnswer((_) async => Right(id!));

    final result = await usecase.execute(entityWithoutId);

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), entityWithId);
    verify(() => repository.save(entityWithoutId));
  });

  test(
    'WHEN the repository returns a Failure THEN usecase should return it too',
    () async {
      final repository = repositoryFn();
      final usecase = usecaseFn();
      when(() => repository.save(any()))
          .thenAnswer((_) async => const Left(FakeFailure('error')));

      final result = await usecase.execute(entityWithoutId);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'error');
      verify(() => repository.save(entityWithoutId));
    },
  );
}

void getUseCaseTests<T extends Entity<ID>, ID>({
  required UseCase<ID, T?> Function() usecaseFn,
  required Repository<T, ID> Function() repositoryFn,
  required T entity,
  required ID id,
}) {
  test('WHEN executed SHOULD return the entity', () async {
    final usecase = usecaseFn();
    final repository = repositoryFn();
    when(() => repository.findById(id)).thenAnswer((_) async => Right(entity));

    final result = await usecase.execute(id);

    expect(result.isRight(), true);
    expect(result.getRight().toNullable(), entity);
    verify(() => repository.findById(id));
  });

  test(
    'WHEN repository returns a failure THEN usecase should return it too',
    () async {
      final usecase = usecaseFn();
      final repository = repositoryFn();
      when(() => repository.findById(id))
          .thenAnswer((_) async => const Left(FakeFailure('error')));

      final result = await usecase.execute(id);

      expect(result.isLeft(), true);
      expect(result.getLeft().toNullable()?.message, 'error');
      verify(() => repository.findById(id));
    },
  );
}

typedef GetResult<T> = Future<Either<Failure, List<T>>>;
typedef GetUseCase<T> = UseCase<Object?, List<T>>;

void getAllUseCaseTests<T extends Entity<ID>, ID>({
  required GetUseCase<T> Function() usecaseFn,
  required Repository<T, ID> Function() repositoryFn,
  required List<T> entities,
  GetResult<T> Function(GetUseCase<T>)? executeUseCaseFn,
  When<GetResult<T>> Function(Repository<T, ID>)? mockRepositoryFn,
  Function(Repository<T, ID>)? verifyRepositoryFn,
}) {
  GetResult<T> executeUsecase(GetUseCase<T> usecase) {
    return (executeUseCaseFn != null
        ? executeUseCaseFn(usecase)
        : usecase.execute(const NoParams()));
  }

  When<GetResult<T>> mockRepository(Repository<T, ID> repository) {
    return (mockRepositoryFn != null
        ? mockRepositoryFn(repository)
        : when(() => repository.findAll()));
  }

  void verifyRepository(Repository<T, ID> repository) {
    (verifyRepositoryFn != null
        ? verifyRepositoryFn(repository)
        : verify(() => repository.findAll()));
  }

  test('WHEN called SHOULD get entities', () async {
    final usecase = usecaseFn();
    final repository = repositoryFn();
    mockRepository(repository).thenAnswer((_) async => Right(entities));

    final result = await executeUsecase(usecase);

    expect(result.getRight().toNullable(), entities);
    verifyRepository(repository);
  });

  test('WHEN repository returns Failure SHOULD return Failure', () async {
    final usecase = usecaseFn();
    final repository = repositoryFn();
    mockRepository(repository)
        .thenAnswer((_) async => const Left(FakeFailure('error')));

    final result = await executeUsecase(usecase);

    expect(result.getLeft().toNullable()?.message, 'error');
    verifyRepository(repository);
  });
}

void deleteUseCaseTests<T extends Entity<ID>, ID>({
  required UseCase<T, void> Function() usecaseFn,
  required Repository<T, ID> Function() repositoryFn,
  required T entityWithId,
  required T entityWithoutId,
  required String errorMessageWithoutId,
}) {
  test('WHEN called SHOULD delete the entity', () async {
    final usecase = usecaseFn();
    final repository = repositoryFn();
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(entityWithId);

    expect(result.isRight(), true);
    verify(() => repository.deleteById(entityWithId.id!));
  });

  test('WHEN entity returns a Failure SHOULD return a Failure too', () async {
    final usecase = usecaseFn();
    final repository = repositoryFn();
    when(() => repository.deleteById(any()))
        .thenAnswer((_) async => const Left(FakeFailure('delete error')));

    final result = await usecase.execute(entityWithId);

    expect(result.getLeft().toNullable()?.message, 'delete error');
    verify(() => repository.deleteById(entityWithId.id!));
  });

  test('WHEN entity doesn\'t have an id SHOULD return a Failure', () async {
    final usecase = usecaseFn();
    final repository = repositoryFn();
    final result = await usecase.execute(entityWithoutId);

    expect(
      result.getLeft().toNullable(),
      BusinessFailure(errorMessageWithoutId),
    );
    verifyNever(() => repository.deleteById(entityWithId.id!));
  });
}
