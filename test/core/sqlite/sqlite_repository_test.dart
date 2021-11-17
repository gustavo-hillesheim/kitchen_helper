import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/sqlite/sqlite_database.dart';
import 'package:kitchen_helper/core/sqlite/sqlite_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late SQLiteRepository<Person> repository;
  late SQLiteDatabase database;

  setUp(() {
    database = MockSQLiteDatabase();
    repository = SQLiteRepository(
      'people',
      database,
      toMap: (p) => p.toJson(),
      fromMap: (map) => Person.fromJson(map),
    );
  });

  test(
    'WHEN creating an entity '
    'SHOULD call the database with correct table and data',
    () async {
      when(() => database.insert(any(), any())).thenAnswer((_) async => 123);

      final result = await repository.create(Person(null, 'Vin Diesel', 32));

      expect(result, const Right(123));
      verify(() => database.insert('people', {
            'id': null,
            'name': 'Vin Diesel',
            'age': 32,
          }));
    },
  );
}

class Person {
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
}
