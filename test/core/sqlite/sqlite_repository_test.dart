import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

import '../../mocks.dart';

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

  group('insert', () {
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

    test(
        'WHEN a DatabaseException is thrown '
        'SHOULD return a Failure', () async {
      when(() => database.insert(any(), any()))
          .thenThrow(FakeDatabaseException('Database error'));

      final result = await repository.create(theRock);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(result.getLeft().toNullable()!.message,
          SQLiteRepository.couldNotInsertMessage);
      verify(() => database.insert(any(), any()));
    });

    test(
        'WHEN an unknown exception is thrown while creating an entity '
        'SHOULD throw exception', () async {
      when(() => database.insert(any(), any()))
          .thenThrow(Exception('Unknown error'));

      try {
        await repository.create(mike);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<Exception>());
        verify(() => database.insert(any(), any()));
      }
    });
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
          Left(RepositoryFailure(SQLiteRepository.canNotUpdateWithIdMessage)),
        );
      },
    );

    test(
        'WHEN a DatabaseException is thrown '
        'SHOULD return a Failure', () async {
      when(() => database.update(any(), any(), any(), any()))
          .thenThrow(FakeDatabaseException('Database error'));

      final result = await repository.update(morpheus);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(result.getLeft().toNullable()?.message,
          SQLiteRepository.couldNotUpdateMessage);
    });

    test(
        'WHEN an unknown Exception is thrown '
        'THEN should throw Exception', () async {
      when(() => database.update(any(), any(), any(), any()))
          .thenThrow(Exception('Unknown error'));

      try {
        await repository.update(sullivan);
        fail('Should have thrown exception');
      } catch (e) {
        verify(() => database.update(any(), any(), any(), any()));
      }
    });
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

    test(
        'WHEN a DatabaseException is thrown '
        'SHOULD return Failure', () async {
      when(() => database.deleteById(any(), any(), any()))
          .thenThrow(FakeDatabaseException('Database error'));

      final result = await repository.deleteById(1);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(result.getLeft().toNullable()?.message,
          SQLiteRepository.couldNotDeleteMessage);
      verify(() => database.deleteById(tableName, idColumn, 1));
    });

    test(
        'WHEN an unknown Exception is thrown '
        'SHOULD throw Exception', () async {
      when(() => database.deleteById(any(), any(), any()))
          .thenThrow(Exception('Unknown error'));

      try {
        await repository.deleteById(1);
        fail('Should have thrown exception');
      } catch (e) {
        verify(() => database.deleteById(any(), any(), any()));
      }
    });
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

    test(
        'WHEN a DatabaseException is thrown '
        'SHOULD return a Failure', () async {
      when(() => database.findAll(any()))
          .thenThrow(FakeDatabaseException('Database error'));

      final result = await repository.findAll();

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(result.getLeft().toNullable()?.message,
          SQLiteRepository.couldNotFindAllMessage);
      verify(() => database.findAll(tableName));
    });

    test(
        'WHEN an unknown Exception is thrown '
        'SHOULD throw Exception', () async {
      when(() => database.findAll(any())).thenThrow(Exception('Unknown error'));

      try {
        await repository.findAll();
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<Exception>());
        verify(() => database.findAll(tableName));
      }
    });
  });

  group('findById', () {
    test('WHEN called SHOULD return element', () async {
      when(() => database.findById(any(), any(), any()))
          .thenAnswer((_) async => neo.toJson());

      final result = await repository.findById(neo.id!);

      expect(result.getRight().toNullable(), neo);
      verify(() => database.findById(tableName, idColumn, neo.id!));
    });

    test(
        'WHEN a DatabaseException is thrown '
        'SHOULD return a Failure', () async {
      when(() => database.findById(any(), any(), any()))
          .thenThrow(FakeDatabaseException('Database error'));

      final result = await repository.findById(neo.id!);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(result.getLeft().toNullable()?.message,
          SQLiteRepository.couldNotFindMessage);
      verify(() => database.findById(tableName, idColumn, neo.id!));
    });

    test(
        'WHEN an unknown Exception is thrown '
        'SHOULD throw Exception', () async {
      when(() => database.findById(any(), any(), any()))
          .thenThrow(Exception('Unknown error'));

      try {
        await repository.findById(neo.id!);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<Exception>());
        verify(() => database.findById(tableName, idColumn, neo.id!));
      }
    });
  });

  group('exists', () {
    test('WHEN called SHOULD return same result as database', () async {
      when(() => database.exists(any(), any(), any()))
          .thenAnswer((_) async => true);

      final result = await repository.exists(neo.id!);

      expect(result.getRight().toNullable(), true);
      verify(() => database.exists(tableName, idColumn, neo.id!));
    });

    test(
        'WHEN a DatabaseException is thrown '
        'SHOULD return a Failure', () async {
      when(() => database.exists(any(), any(), any()))
          .thenThrow(FakeDatabaseException('Database error'));

      final result = await repository.exists(neo.id!);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(result.getLeft().toNullable()?.message,
          SQLiteRepository.couldNotVerifyExistenceMessage);
      verify(() => database.exists(tableName, idColumn, neo.id!));
    });

    test(
        'WHEN an unknown Exception is thrown '
        'SHOULD throw Exception', () async {
      when(() => database.exists(any(), any(), any()))
          .thenThrow(Exception('Unknown error'));

      try {
        await repository.exists(neo.id!);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<Exception>());
        verify(() => database.exists(tableName, idColumn, neo.id!));
      }
    });
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

class FakeDatabaseException extends DatabaseException {
  FakeDatabaseException(String message) : super(message);

  @override
  int? getResultCode() {
    throw UnimplementedError();
  }
}
