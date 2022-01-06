import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

import '../../mocks.dart';

void main() {
  late Database sqfliteDatabase;
  late SQLiteDatabase database;

  setUp(() {
    sqfliteDatabase = DatabaseMock();
    database = SQLiteDatabase(sqfliteDatabase);
  });

  void mockInsert(DatabaseExecutor executor, int result) {
    when(() => executor.insert(any(), any())).thenAnswer((_) async => result);
  }

  void mockUpdate(DatabaseExecutor executor, int result) {
    when(() => executor.update(any(), any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => result);
  }

  void mockDelete(DatabaseExecutor executor, int result) {
    when(() => executor.delete(any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => result);
  }

  void mockQuery(DatabaseExecutor executor, List<Map<String, dynamic>> result) {
    when(() => executor.query(any(),
        columns: any(named: 'columns'),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => result);
  }

  void mockRawQuery(
      DatabaseExecutor executor, List<Map<String, dynamic>> result) {
    when(() => executor.rawQuery(any(), any())).thenAnswer((_) async => result);
  }

  test('WHEN insert is called SHOULD insert the register', () async {
    mockInsert(sqfliteDatabase, 1);

    final result = await database.insert('people', {'name': 'Johnson'});

    expect(result, 1);
    verify(() => sqfliteDatabase.insert('people', {'name': 'Johnson'}));
  });

  test('WHEN update is called SHOULD update the register', () async {
    mockUpdate(sqfliteDatabase, 1);

    await database.update('people', {'name': 'Mike'}, 'id', 1);

    verify(() => sqfliteDatabase.update(
          'people',
          {'name': 'Mike'},
          where: 'id = ?',
          whereArgs: [1],
        ));
  });

  test(
    'WHEN deleteById is called SHOULD delete the register',
    () async {
      mockDelete(sqfliteDatabase, 1);

      await database.deleteById('people', 'id', 2);

      verify(() =>
          sqfliteDatabase.delete('people', where: 'id = ?', whereArgs: [2]));
    },
  );

  test('WHEN findAll is called SHOULD query registers', () async {
    mockQuery(sqfliteDatabase, [
      {'name': 'mike', 'id': 1}
    ]);

    final result = await database.findAll('people');

    expect(result, [
      {'name': 'mike', 'id': 1}
    ]);
    verify(() => sqfliteDatabase.query('people'));
  });

  test(
    'WHEN findById is called SHOULD return the first register found',
    () async {
      mockQuery(sqfliteDatabase, [
        {'name': 'mike', 'person_id': 1},
        {'name': 'Johnson', 'person_id': 1},
      ]);

      final result = await database.findById('people', 'person_id', 1);

      expect(result, {'name': 'mike', 'person_id': 1});
      verify(() => sqfliteDatabase
          .query('people', where: 'person_id = ?', whereArgs: [1]));
    },
  );

  test(
    'WHEN findById is called AND nothing is found should return null',
    () async {
      mockQuery(sqfliteDatabase, []);

      final result = await database.findById('people', 'id_column', 1);

      expect(result, null);
      verify(() => sqfliteDatabase
          .query('people', where: 'id_column = ?', whereArgs: [1]));
    },
  );

  test(
    'WHEN exists is called AND no register exist SHOULD return false',
    () async {
      mockRawQuery(sqfliteDatabase, []);

      final result = await database.exists('people', 'id', 1);

      expect(result, false);
      verify(() =>
          sqfliteDatabase.rawQuery('select 1 from people where id = ?', [1]));
    },
  );

  test(
    'WHEN exists is called AND a register exist SHOULD return true',
    () async {
      mockRawQuery(sqfliteDatabase, [
        {'1': 1}
      ]);

      final result = await database.exists('people', 'id', 1);

      expect(result, true);
      verify(() => sqfliteDatabase.rawQuery(
          'select 1 from people where id = '
          '?',
          [1]));
    },
  );

  test(
      'WHEN query is called without a where map '
      'SHOULD execute the query correctly', () async {
    mockQuery(sqfliteDatabase, []);

    final result =
        await database.query(table: 'people', columns: ['name', 'age', 'id']);

    expect(result, []);
    verify(
        () => sqfliteDatabase.query('people', columns: ['name', 'age', 'id']));
  });

  test(
      'WHEN query is called with a where map SHOULD execute the query '
      'correctly', () async {
    mockQuery(sqfliteDatabase, []);

    final result = await database.query(
      table: 'people',
      columns: ['name', 'age', 'id'],
      where: {'age': 20},
    );

    expect(result, []);
    verify(() => sqfliteDatabase.query('people',
        columns: ['name', 'age', 'id'], where: 'age = ?', whereArgs: [20]));
  });

  test(
      'WHEN query is called with a where map with multiple values '
      'SHOULD execute the query correctly', () async {
    mockQuery(sqfliteDatabase, []);

    final result = await database.query(
      table: 'people',
      columns: ['name', 'age', 'id'],
      where: {
        'age': 20,
        'id': 2,
      },
    );

    expect(result, []);
    verify(() => sqfliteDatabase.query('people',
        columns: ['name', 'age', 'id'],
        where: 'age = ? AND id = ?',
        whereArgs: [20, 2]));
  });

  test(
      'WHEN insideTransaction is called '
      'SHOULD perform the actions inside a transaction', () async {
    final transaction = TransactionMock();
    mockInsert(transaction, 1);
    mockUpdate(transaction, 1);
    mockQuery(transaction, []);
    mockDelete(transaction, 1);
    mockRawQuery(transaction, []);

    when(() => sqfliteDatabase.transaction(any())).thenAnswer(
        (invocation) => invocation.positionalArguments[0](transaction));

    final result = await database.insideTransaction(() async {
      await database.insert('people', {'name': 'mike'});
      await database.update('people', {'name': 'johnson'}, 'id', 1);
      await database.findById('people', 'id', 1);
      await database.findAll('people');
      await database.deleteById('people', 'id', 1);
      await database.exists('people', 'id', 1);
      await database.query(table: 'people', columns: ['name', 'id']);
      return 'Executed';
    });

    expect(result, 'Executed');
    verify(() => transaction.insert('people', {'name': 'mike'}));
    verify(() => transaction.update('people', {'name': 'johnson'},
        where: 'id = ?', whereArgs: [1]));
    verify(() => transaction.query('people', where: 'id = ?', whereArgs: [1]));
    verify(() => transaction.query('people'));
    verify(() => transaction.delete('people', where: 'id = ?', whereArgs: [1]));
    verify(
        () => transaction.rawQuery('select 1 from people where id = ?', [1]));
    verify(() => transaction.query('people', columns: ['name', 'id']));
  });

  test(
      'WHEN the action inside a transaction returns an Failure Either'
      'SHOULD throw an exception AND return the Either', () async {
    final transaction = TransactionMock();
    when(() => sqfliteDatabase.transaction(any())).thenAnswer(
        (invocation) => invocation.positionalArguments[0](transaction));

    final result = await database.insideTransaction(() {
      return Left(FakeFailure('fake error'));
    });

    expect(result, Left(FakeFailure('fake error')));
  });

  test('WHEN delete is called SHOULD delete the registers', () async {
    when(() => sqfliteDatabase.delete(any(),
        where: any(named: 'where'),
        whereArgs: any(named: 'whereArgs'))).thenAnswer((_) async => 1);

    await database.delete(table: 'people', where: {'age': 20});

    verify(() =>
        sqfliteDatabase.delete('people', where: 'age = ?', whereArgs: [20]));
  });
}

class DatabaseMock extends Mock implements Database {}

class TransactionMock extends Mock implements Transaction {}
