import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/orders/data/repository/sqlite_order_discount_repository.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late SQLiteOrderDiscountRepository repository;
  late SQLiteDatabase database;

  setUp(() {
    database = SQLiteDatabaseMock();
    repository = SQLiteOrderDiscountRepository(database);
  });

  group('deleteByOrder', () {
    When<Future<void>> mockDelete() {
      return when(() => database.delete(
            table: any(named: 'table'),
            where: any(named: 'where'),
          ));
    }

    test('WHEN called SHOULD execute query to delete discounts', () async {
      mockDelete().thenAnswer((_) async {});

      final result = await repository.deleteByOrder(1);

      expect(result.isRight(), true);
      verify(() => database.delete(
            table: repository.tableName,
            where: {'orderId': 1},
          ));
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      mockDelete().thenThrow(FakeDatabaseException('error message'));

      final result = await repository.deleteByOrder(1);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotDeleteMessage,
      );
      verify(() => database.delete(
            table: repository.tableName,
            where: {'orderId': 1},
          ));
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      mockDelete().thenThrow(Exception('error message'));

      try {
        await repository.deleteByOrder(1);
        fail('Should have thrown exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
      verify(() => database.delete(
            table: repository.tableName,
            where: {'orderId': 1},
          ));
    });
  });

  When<Future<List<Map<String, dynamic>>>> mockQuery() {
    return when(() => database.query(
          table: any(named: 'table'),
          columns: any(named: 'columns'),
          where: any(named: 'where'),
        ));
  }

  group('findByOrder', () {
    test('WHEN called SHOULD execute query on database', () async {
      mockQuery().thenAnswer(
        (_) async => [
          fixedDiscountEntity.toJson(),
          percentageDiscountEntity.toJson(),
        ],
      );

      final result = await repository.findByOrder(1);

      expect(result.isRight(), true);
      expect(
        result.getRight().toNullable(),
        [fixedDiscountEntity, percentageDiscountEntity],
      );
      verify(() => database.query(
            table: repository.tableName,
            columns: ['id', 'orderId', 'reason', 'type', 'value'],
            where: {'orderId': 1},
          ));
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      mockQuery().thenThrow(FakeDatabaseException('error'));

      final result = await repository.findByOrder(1);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotQueryMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      mockQuery().thenThrow(Exception('exception'));

      try {
        await repository.findByOrder(1);
        fail('Should have thrown Exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('findId', () {
    test('WHEN called SHOULD execute query on database', () async {
      mockQuery().thenAnswer((_) async => [
            {'id': 1}
          ]);

      final result = await repository.findId(1, fixedDiscount);

      expect(result.getRight().toNullable(), 1);
      verify(() => database.query(table: repository.tableName, columns: [
            'id'
          ], where: {
            'orderId': 1,
            'reason': fixedDiscount.reason,
            'type': fixedDiscount.type.name,
            'value': fixedDiscount.value,
          }));
    });

    test('WHEN nothing is found SHOULD return null', () async {
      mockQuery().thenAnswer((_) async => []);

      final result = await repository.findId(1, fixedDiscount);

      expect(result.getRight().toNullable(), null);
    });

    test('WHEN multiple values are found SHOULD return the first one',
        () async {
      mockQuery().thenAnswer((_) async => [
            {'id': 3},
            {'id': 2}
          ]);

      final result = await repository.findId(1, fixedDiscount);

      expect(result.getRight().toNullable(), 3);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      mockQuery().thenThrow(FakeDatabaseException('error'));

      final result = await repository.findId(1, fixedDiscount);

      expect(result.getLeft().toNullable(), isA<DatabaseFailure>());
      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotQueryMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD throw Exception',
        () async {
      mockQuery().thenThrow(Exception('exception'));

      try {
        await repository.findId(1, fixedDiscount);
        fail('Should have thrown Exception');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}

const fixedDiscount = Discount(
  reason: 'Fixed discount reason',
  type: DiscountType.fixed,
  value: 50,
);
const fixedDiscountEntity = OrderDiscountEntity(
  id: 1,
  orderId: 2,
  reason: 'Fixed discount reason',
  type: DiscountType.fixed,
  value: 50,
);
const percentageDiscountEntity = OrderDiscountEntity(
  id: 2,
  orderId: 2,
  reason: 'Percentage discount reason',
  type: DiscountType.percentage,
  value: 10,
);
