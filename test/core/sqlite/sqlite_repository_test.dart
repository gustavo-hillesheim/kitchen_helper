import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

import '../../mocks.dart';
import '../../sqlite_repository_tests.dart';

void main() {
  const idColumn = 'id';
  const tableName = 'people';
  late SQLiteRepository<Person> repository;
  late SQLiteDatabase database;

  final vinDiesel = Person(null, 'Vin Diesel', 32);
  final theRock = Person(null, 'The rock', 35);
  final mike = Person(null, 'Mike', 15);
  final neo = Person(1, 'Neo', 25);
  final trinity = Person(null, 'Trinity', 30);
  final morpheus = Person(2, 'Morpheus', 45);
  final sullivan = Person(3, 'Sullivan', 28);

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteRepository(
      tableName,
      idColumn,
      database,
      toMap: (p) => p.toJson(),
      fromMap: (map) => Person.fromJson(map),
    );
  });

  group('create', () {
    test(
      'WHEN creating an entity '
      'SHOULD call the database with correct table and data',
      () async {
        when(() => database.insert(any(), any())).thenAnswer((_) async => 123);

        final result = await repository.create(vinDiesel);

        expect(result, const Right(123));
        verify(() => database.insert(tableName, vinDiesel.toJson()));
      },
    );

    testExceptionsOnCreate(() => repository, () => database, theRock);
  });

  group('update', () {
    test(
        'WHEN updating an entity '
        'SHOULD call the database with correct table and data', () async {
      when(() => database.update(any(), any(), any(), any()))
          .thenAnswer((_) async => const Left(null));

      final result = await repository.update(neo);

      expect(result, const Right(null));
      verify(() => database.update(tableName, neo.toJson(), idColumn, 1));
    });

    test(
      'WHEN updating an entity without id '
      'SHOULD return a Failure',
      () async {
        final result = await repository.update(trinity);

        expect(
          result,
          const Left(
              RepositoryFailure(SQLiteRepository.canNotUpdateWithIdMessage)),
        );
      },
    );

    testExceptionsOnUpdate(() => repository, () => database, morpheus);
  });

  group('deleteById', () {
    test(
      'WHEN deleting SHOULD call repository with correct arguments',
      () async {
        when(() => database.deleteById(any(), any(), any()))
            .thenAnswer((_) async => const Right(null));

        final result = await repository.deleteById(1);

        expect(result, const Right(null));
        verify(() => database.deleteById(tableName, idColumn, 1));
      },
    );

    testExceptionsOnDeleteById(
      () => repository,
      () => database,
      tableName,
      idColumn,
    );
  });

  group('findAll', () {
    test('WHEN called SHOULD return all elements', () async {
      when(() => database.findAll(any())).thenAnswer(
          (_) async => [neo.toJson(), morpheus.toJson(), sullivan.toJson()]);

      final result = await repository.findAll();

      expect(
        const ListEquality()
            .equals(result.getRight().toNullable(), [neo, morpheus, sullivan]),
        true,
      );
      verify(() => database.findAll(tableName));
    });

    testExceptionsOnFindAll(() => repository, () => database, tableName);
  });

  group('findById', () {
    test('WHEN called SHOULD return element', () async {
      when(() => database.findById(any(), any(), any()))
          .thenAnswer((_) async => neo.toJson());

      final result = await repository.findById(neo.id!);

      expect(result.getRight().toNullable(), neo);
      verify(() => database.findById(tableName, idColumn, neo.id!));
    });

    testExceptionsOnFindById(() => repository, () => database);
  });

  group('exists', () {
    test('WHEN called SHOULD return same result as database', () async {
      when(() => database.exists(any(), any(), any()))
          .thenAnswer((_) async => true);

      final result = await repository.exists(neo.id!);

      expect(result.getRight().toNullable(), true);
      verify(() => database.exists(tableName, idColumn, neo.id!));
    });

    testExceptionsOnExists(
      () => repository,
      () => database,
      tableName,
      idColumn,
      neo.id!,
    );
  });

  group('save', () {
    test(
      'WHEN the repository is called with a register without id '
      'THEN it should create a new register',
      () async {
        when(() => database.insert(any(), any())).thenAnswer((_) async => 1);

        final result = await repository.save(mike);

        expect(result.isRight(), true);
        expect(result.getRight().toNullable(), 1);
        verifyNever(() => database.exists(any(), any(), any()));
        verify(() => database.insert(tableName, mike.toJson()));
      },
    );

    test(
      'WHEN the repository is called with a register with id that exists '
      'THEN it should update the register',
      () async {
        when(() => database.exists(any(), any(), any()))
            .thenAnswer((_) async => true);
        when(() => database.update(any(), any(), any(), any()))
            .thenAnswer((_) async {});

        final result = await repository.save(neo);

        expect(result.isRight(), true);
        verify(() => database.exists(tableName, idColumn, neo.id!));
        verify(
            () => database.update(tableName, neo.toJson(), idColumn, neo.id!));
      },
    );

    test(
      'WHEN the usecase is called with a register with id that doesn\'t exists '
      'THEN it should create the register',
      () async {
        when(() => database.exists(any(), any(), any()))
            .thenAnswer((_) async => false);
        when(() => database.insert(any(), any())).thenAnswer((_) async => 1);

        final result = await repository.save(neo);

        expect(result.isRight(), true);
        expect(result.getRight().toNullable(), 1);
        verify(() => database.exists(tableName, idColumn, neo.id!));
        verify(() => database.insert(tableName, neo.toJson()));
      },
    );

    testExceptionsOnSave(
        () => repository, () => database, tableName, idColumn, neo);
  });

  group('deleteWhere', () {
    test('WHEN called SHOULD delete using the query', () async {
      when(() => database.delete(
          table: any(named: 'table'),
          where: any(named: 'where'))).thenAnswer((_) async {});

      final result = await repository.deleteWhere({'name': neo.name});

      expect(result.isRight(), true);
      verify(
          () => database.delete(table: tableName, where: {'name': neo.name}));
    });

    testExceptionsOnDeleteWhere(
      () => repository,
      () => database,
      tableName,
      {'name': neo.name},
    );
  });
}

class Person extends Entity<int> with EquatableMixin {
  @override
  final int? id;
  final String name;
  final int age;

  Person(this.id, this.name, this.age);

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(json['id'], json['name'], json['age']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
      };

  @override
  List<Object?> get props => [id, name, age];
}

class TransactionMock extends Mock implements Transaction {}
