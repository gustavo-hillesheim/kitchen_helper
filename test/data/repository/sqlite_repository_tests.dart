/// This library contains pre-made tests for SQLiteRepositories
library sqlite_repository_tests;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/database.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void testExceptionsOnFindById(
  SQLiteRepository Function() repositoryFn,
  SQLiteDatabase Function() databaseFn, {
  void Function()? verifications,
}) {
  test(
      'WHEN database throws a DatabaseException '
      'SHOULD return Failure', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    final exception = FakeDatabaseException('error on database');
    when(() => database.findById(any(), any(), any())).thenThrow(exception);

    final result = await repository.findById(1);

    expect(result.getLeft().toNullable(),
        DatabaseFailure(SQLiteRepository.couldNotFindMessage, exception));
    verify(
        () => database.findById(repository.tableName, repository.idColumn, 1));
    if (verifications != null) {
      verifications();
    }
  });

  test(
      'WHEN database throws an unknown Exception '
      'SHOULD throw Exception', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    final exception = Exception('internal error');
    when(() => database.findById(any(), any(), any())).thenThrow(exception);

    try {
      await repository.findById(1);
      fail('Should have thrown exception');
    } on Exception catch (e) {
      expect(e, exception);
    }
    verify(
        () => database.findById(repository.tableName, repository.idColumn, 1));
    if (verifications != null) {
      verifications();
    }
  });
}

void testExceptionsOnCreate<T extends Entity<int>>(
  SQLiteRepository<T> Function() repositoryFn,
  SQLiteDatabase Function() databaseFn,
  T testEntity,
) {
  test(
      'WHEN a DatabaseException is thrown '
      'SHOULD return a Failure', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.insert(any(), any()))
        .thenThrow(FakeDatabaseException('Database error'));

    final result = await repository.create(testEntity);

    expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
    expect(result.getLeft().toNullable()!.message,
        SQLiteRepository.couldNotInsertMessage);
    verify(() => database.insert(any(), any()));
  });

  test(
      'WHEN an unknown exception is thrown while creating an entity '
      'SHOULD throw exception', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.insert(any(), any()))
        .thenThrow(Exception('Unknown error'));

    try {
      await repository.create(testEntity);
      fail('Should have thrown exception');
    } catch (e) {
      expect(e, isA<Exception>());
      verify(() => database.insert(any(), any()));
    }
  });
}

void testExceptionsOnUpdate<T extends Entity<int>>(
  SQLiteRepository<T> Function() repositoryFn,
  SQLiteDatabase Function() databaseFn,
  T testEntity,
) {
  test(
      'WHEN a DatabaseException is thrown '
      'SHOULD return a Failure', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.update(any(), any(), any(), any()))
        .thenThrow(FakeDatabaseException('Database error'));

    final result = await repository.update(testEntity);

    expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
    expect(result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotUpdateMessage);
  });

  test(
      'WHEN an unknown Exception is thrown '
      'THEN should throw Exception', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.update(any(), any(), any(), any()))
        .thenThrow(Exception('Unknown error'));

    try {
      await repository.update(testEntity);
      fail('Should have thrown exception');
    } catch (e) {
      verify(() => database.update(any(), any(), any(), any()));
    }
  });
}

void testExceptionsOnDeleteById(
  SQLiteRepository Function() repositoryFn,
  SQLiteDatabase Function() databaseFn,
  String tableName,
  String idColumn, {
  void Function()? verifications,
}) {
  test(
      'WHEN a DatabaseException is thrown '
      'SHOULD return Failure', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.deleteById(any(), any(), any()))
        .thenThrow(FakeDatabaseException('Database error'));

    final result = await repository.deleteById(1);

    expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
    expect(result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotDeleteMessage);
    verify(() => database.deleteById(tableName, idColumn, 1));
    if (verifications != null) {
      verifications();
    }
  });

  test(
      'WHEN an unknown Exception is thrown '
      'SHOULD throw Exception', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.deleteById(any(), any(), any()))
        .thenThrow(Exception('Unknown error'));

    try {
      await repository.deleteById(1);
      fail('Should have thrown exception');
    } catch (e) {
      verify(() => database.deleteById(any(), any(), any()));
    }
    if (verifications != null) {
      verifications();
    }
  });
}

void testExceptionsOnFindAll(
  SQLiteRepository Function() repositoryFn,
  SQLiteDatabase Function() databaseFn,
  String tableName, {
  void Function()? verifications,
}) {
  test(
      'WHEN a DatabaseException is thrown '
      'SHOULD return a Failure', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.findAll(any()))
        .thenThrow(FakeDatabaseException('Database error'));

    final result = await repository.findAll();

    expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
    expect(result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage);
    verify(() => database.findAll(tableName));
    if (verifications != null) {
      verifications();
    }
  });

  test(
      'WHEN an unknown Exception is thrown '
      'SHOULD throw Exception', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.findAll(any())).thenThrow(Exception('Unknown error'));

    try {
      await repository.findAll();
      fail('Should have thrown exception');
    } catch (e) {
      expect(e, isA<Exception>());
      verify(() => database.findAll(tableName));
      if (verifications != null) {
        verifications();
      }
    }
  });
}

void testExceptionsOnExists(
  SQLiteRepository Function() repositoryFn,
  SQLiteDatabase Function() databaseFn,
  String tableName,
  String idColumn,
  int testId,
) {
  test(
      'WHEN a DatabaseException is thrown '
      'SHOULD return a Failure', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.exists(any(), any(), any()))
        .thenThrow(FakeDatabaseException('Database error'));

    final result = await repository.exists(testId);

    expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
    expect(result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotVerifyExistenceMessage);
    verify(() => database.exists(tableName, idColumn, testId));
  });

  test(
      'WHEN an unknown Exception is thrown '
      'SHOULD throw Exception', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.exists(any(), any(), any()))
        .thenThrow(Exception('Unknown error'));

    try {
      await repository.exists(testId);
      fail('Should have thrown exception');
    } catch (e) {
      expect(e, isA<Exception>());
      verify(() => database.exists(tableName, idColumn, testId));
    }
  });
}

void testExceptionsOnSave<T extends Entity<int>>(
  SQLiteRepository<T> Function() repositoryFn,
  SQLiteDatabase Function() databaseFn,
  String tableName,
  String idColumn,
  T testEntity,
) {
  test(
    'WHEN the database throws an Exception on insert '
    'THEN the repository should return a Failure',
    () async {
      final database = databaseFn();
      final repository = repositoryFn();
      final exception = FakeDatabaseException('insert error');
      when(() => database.exists(any(), any(), any()))
          .thenAnswer((_) async => false);
      when(() => database.insert(any(), any())).thenThrow(exception);

      final result = await repository.save(testEntity);

      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()! as DatabaseFailure;
      expect(failure.message, SQLiteRepository.couldNotInsertMessage);
      expect(failure.exception, exception);
      verify(
          () => database.insert(tableName, (testEntity as dynamic).toJson()));
    },
  );

  test(
    'WHEN the database throws an Exception on update '
    'THEN the repository should return a Failure',
    () async {
      final database = databaseFn();
      final repository = repositoryFn();
      final exception = FakeDatabaseException('update error');
      when(() => database.exists(any(), any(), any()))
          .thenAnswer((_) async => true);
      when(() => database.update(any(), any(), any(), any()))
          .thenThrow(exception);

      final result = await repository.save(testEntity);

      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()! as DatabaseFailure;
      expect(failure.message, SQLiteRepository.couldNotUpdateMessage);
      expect(failure.exception, exception);
      verify(() => database.update(tableName, (testEntity as dynamic).toJson(),
          idColumn, testEntity.id!));
    },
  );

  test(
    'WHEN the database throws an Exception on exists '
    'THEN the repository should return a Failure',
    () async {
      final database = databaseFn();
      final repository = repositoryFn();
      final exception = FakeDatabaseException('exists error');
      when(() => database.exists(any(), any(), any())).thenThrow(exception);

      final result = await repository.save(testEntity);

      expect(result.isLeft(), true);
      final failure = result.getLeft().toNullable()! as DatabaseFailure;
      expect(failure.message, SQLiteRepository.couldNotVerifyExistenceMessage);
      expect(failure.exception, exception);
      verify(() => database.exists(tableName, idColumn, testEntity.id!));
    },
  );
}

void testExceptionsOnDeleteWhere(
  SQLiteRepository Function() repositoryFn,
  SQLiteDatabase Function() databaseFn,
  String tableName,
  Map<String, dynamic> where,
) {
  test(
      'WHEN a DatabaseException is thrown '
      'SHOULD return a Failure', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.delete(
            table: any(named: 'table'), where: any(named: 'where')))
        .thenThrow(FakeDatabaseException('Database error'));

    final result = await repository.deleteWhere(where);

    expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
    expect(result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotDeleteMessage);
    verify(() => database.delete(table: tableName, where: where));
  });

  test(
      'WHEN an unknown Exception is thrown '
      'SHOULD throw Exception', () async {
    final database = databaseFn();
    final repository = repositoryFn();
    when(() => database.delete(
        table: any(named: 'table'),
        where: any(named: 'where'))).thenThrow(Exception('Unknown error'));

    try {
      await repository.deleteWhere(where);
      fail('Should have thrown exception');
    } catch (e) {
      expect(e, isA<Exception>());
      verify(() => database.delete(table: tableName, where: where));
    }
  });
}
