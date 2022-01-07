import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/data/repository/sqlite_order_product_repository.dart';
import 'package:kitchen_helper/data/repository/sqlite_order_repository.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';
import 'sqlite_repository_tests.dart';

void main() {
  late SQLiteOrderRepository repository;
  late OrderProductRepository orderProductRepository;
  late SQLiteDatabase database;
  const tableName = 'orders';
  const idColumn = 'id';

  setUp(() {
    registerFallbackValue(FakeOrderProductEntity());
    database = SQLiteDatabaseMock();
    orderProductRepository = OrderProductRepositoryMock();
    repository = SQLiteOrderRepository(database, orderProductRepository);
  });

  test('toMap SHOULD remove products field', () {
    final map = repository.toMap(spidermanOrder);
    expect(map, spidermanOrder.toJson()..remove('products'));
  });

  test('fromMap SHOULD set products field to empty', () {
    final order = repository.fromMap(spidermanOrder.toJson());
    expect(order, spidermanOrder.copyWith(products: []));
  });

  When<Future<Either<Failure, List<OrderProductEntity>>>> mockFindByOrder() {
    return when(() => orderProductRepository.findByOrder(any()));
  }

  When<Future<Either<Failure, void>>> mockDeleteByOrder() {
    return when(() => orderProductRepository.deleteByOrder(any()));
  }

  When<Future<Either<Failure, int>>> mockCreate() {
    return when(() => orderProductRepository.create(any()));
  }

  When<Future<T>> mockTransaction<T>() {
    return when(() => database.insideTransaction(any()));
  }

  Future<T> executeTransaction<T>(Invocation invocation) async {
    final fn = invocation.positionalArguments[0];
    return await fn();
  }

  group('findById', () {
    When<Future<Map<String, dynamic>?>> mockFindById() {
      return when(() => database.findById(any(), any(), any()));
    }

    test('WHEN finds order SHOULD fill products with orderProductRepository',
        () async {
      mockFindById().thenAnswer((_) async => repository.toMap(batmanOrder));
      mockFindByOrder().thenAnswer(
        (_) async => Right([
          cakeOrderProductEntityWithId,
          iceCreamOrderProductEntityWithId,
        ]),
      );

      final result = await repository.findById(batmanOrder.id!);

      expect(result.getRight().toNullable(), batmanOrder);
      verify(() => database.findById(tableName, idColumn, batmanOrder.id!));
      verify(() => orderProductRepository.findByOrder(batmanOrder.id!));
    });

    test('WHEN finds no order SHOULD not call orderProductRepository',
        () async {
      mockFindById().thenAnswer((_) async => null);

      final result = await repository.findById(batmanOrder.id!);

      expect(result.getRight().toNullable(), isNull);
      verify(() => database.findById(tableName, idColumn, batmanOrder.id!));
      verifyNever(() => orderProductRepository.findByOrder(any()));
    });

    test('WHEN orderProductRepository returns Failure SHOULD return Failure',
        () async {
      const failure = FakeFailure('failure');
      mockFindById().thenAnswer((_) async => repository.toMap(batmanOrder));
      mockFindByOrder().thenAnswer((_) async => const Left(failure));

      final result = await repository.findById(batmanOrder.id!);

      expect(result.getLeft().toNullable(), failure);
    });

    testExceptionsOnFindById(
      () => repository,
      () => database,
      verifications: () {
        verifyNever(() => orderProductRepository.findByOrder(any()));
      },
    );
  });

  group('findAll', () {
    When<Future<List<Map<String, dynamic>>>> mockFindAll() {
      return when(() => database.findAll(any()));
    }

    test(
        'WHEN finds orders '
        'SHOULD fill products with orderProductRepository', () async {
      mockFindAll().thenAnswer((_) async => [
            repository.toMap(batmanOrder),
            repository.toMap(batmanOrder),
          ]);
      mockFindByOrder().thenAnswer((invocation) async {
        final orderId = invocation.positionalArguments[0];
        return Right({
          batmanOrder.id!: [cakeOrderProductEntityWithId],
          batmanOrder.id!: [
            cakeOrderProductEntityWithId,
            iceCreamOrderProductEntityWithId
          ],
        }[orderId]!);
      });

      final result = await repository.findAll();

      expect(result.getRight().toNullable(), [batmanOrder, batmanOrder]);
      verify(() => database.findAll(tableName));
      verify(
        () => orderProductRepository.findByOrder(batmanOrder.id!),
      ).called(2);
    });

    test('WHEN finds no order SHOULD not call orderProductRepository',
        () async {
      mockFindAll().thenAnswer((_) async => []);

      final result = await repository.findAll();

      expect(result.getRight().toNullable(), []);
      verify(() => database.findAll(tableName));
      verifyNever(() => orderProductRepository.findByOrder(any()));
    });

    test('WHEN orderProductRepository returns Failure SHOULD return Failure',
        () async {
      const failure = FakeFailure('failure');
      mockFindAll().thenAnswer(
        (_) async => [repository.toMap(batmanOrder)],
      );
      mockFindByOrder().thenAnswer((_) async => const Left(failure));

      final result = await repository.findAll();

      expect(result.getLeft().toNullable(), failure);
      verify(() => database.findAll(tableName));
      verify(
        () => orderProductRepository.findByOrder(batmanOrder.id!),
      );
    });

    testExceptionsOnFindAll(
      () => repository,
      () => database,
      tableName,
      verifications: () {
        verifyNever(() => orderProductRepository.findByOrder(any()));
      },
    );
  });

  group('deleteById', () {
    When<Future<void>> mockDeleteById() {
      return when(() => database.deleteById(any(), any(), any()));
    }

    test('WHEN deletes order SHOULD delete order products', () async {
      mockDeleteById().thenAnswer((_) async {});
      mockDeleteByOrder().thenAnswer((_) async => const Right(null));
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.deleteById(tableName, idColumn, batmanOrder.id!));
        verify(
          () => orderProductRepository.deleteByOrder(batmanOrder.id!),
        );
        return result;
      });

      final result = await repository.deleteById(batmanOrder.id!);

      expect(result.isRight(), true);
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to delete order SHOULD NOT delete order products',
        () async {
      mockDeleteById().thenThrow(FakeDatabaseException('could not delete'));
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.deleteById(tableName, idColumn, batmanOrder.id!));
        verifyNever(() => orderProductRepository.deleteByOrder(any()));
        return result;
      });

      final result = await repository.deleteById(batmanOrder.id!);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotDeleteMessage,
      );
      verify(() => database.insideTransaction(any()));
    });

    test(
        'WHEN orderProductsRepository returns Failure '
        'SHOULD return Failure', () async {
      mockDeleteById().thenAnswer((_) async {});
      mockDeleteByOrder().thenAnswer(
        (_) async => const Left(FakeFailure('failure')),
      );
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.deleteById(tableName, idColumn, batmanOrder.id!));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        return result;
      });

      final result = await repository.deleteById(batmanOrder.id!);

      expect(result.getLeft().toNullable()?.message, 'failure');
      verify(() => database.insideTransaction(any()));
    });

    testExceptionsOnDeleteById(
      () => repository,
      () {
        mockTransaction<Either<Failure, void>>().thenAnswer(executeTransaction);
        return database;
      },
      tableName,
      idColumn,
      verifications: () {
        verifyNever(() => orderProductRepository.deleteByOrder(any()));
      },
    );
  });

  group('create', () {
    When<Future<int>> mockInsert() {
      return when(() => database.insert(tableName, any()));
    }

    test('WHEN creates order SHOULD create orderProducts', () async {
      final ids = [
        iceCreamOrderProductEntityWithId.id!,
        cakeOrderProductEntityWithId.id!
      ];
      mockTransaction<Either<Failure, int>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.insert(tableName, repository.toMap(batmanOrder)));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        return result;
      });
      mockInsert().thenAnswer((_) async => batmanOrder.id!);
      mockCreate().thenAnswer((_) async => Right(ids.removeLast()));

      final result = await repository.create(batmanOrder);

      expect(result.getRight().toNullable(), batmanOrder.id!);
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to create order SHOULD NOT create orderProducts',
        () async {
      mockTransaction<Either<Failure, int>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.insert(tableName, repository.toMap(batmanOrder)));
        verifyNever(() => orderProductRepository.create(any()));
        return result;
      });
      mockInsert().thenThrow(FakeDatabaseException('insert exception'));

      final result = await repository.create(batmanOrder);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotInsertMessage,
      );
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN orderProductRepository retuns Failure SHOULD return Failure',
        () async {
      mockTransaction<Either<Failure, int>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.insert(tableName, repository.toMap(batmanOrder)));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        return result;
      });
      mockInsert().thenAnswer((_) async => batmanOrder.id!);
      mockCreate().thenAnswer(
        (_) async => const Left(FakeFailure('failure')),
      );

      final result = await repository.create(batmanOrder);

      expect(result.getLeft().toNullable()?.message, 'failure');
      verify(() => database.insideTransaction(any()));
    });

    testExceptionsOnCreate(
      () => repository,
      () {
        mockTransaction<Either<Failure, int>>().thenAnswer(executeTransaction);
        return database;
      },
      batmanOrder,
    );
  });

  group('update', () {
    When<Future<void>> mockUpdate() {
      return when(() => database.update(any(), any(), any(), any()));
    }

    test('WHEN updates order SHOULD recreate orderProducts', () async {
      final ids = [
        iceCreamOrderProductEntityWithId.id!,
        cakeOrderProductEntityWithId.id!,
      ];
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()..remove('products'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockDeleteByOrder().thenAnswer((_) async => const Right(null));
      mockCreate().thenAnswer((_) async => Right(ids.removeLast()));

      final result = await repository.update(batmanOrder);

      expect(result.isRight(), true);
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to update order SHOULD not recreate orderProducts',
        () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()..remove('products'),
              idColumn,
              batmanOrder.id!,
            ));
        verifyNever(() => orderProductRepository.deleteByOrder(any()));
        verifyNever(() => orderProductRepository.create(any()));
        return result;
      });
      mockUpdate().thenThrow(FakeDatabaseException('exception'));

      final result = await repository.update(batmanOrder);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotUpdateMessage,
      );
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to delete orderProducts SHOULD not recreate them',
        () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()..remove('products'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verifyNever(() => orderProductRepository.create(any()));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockDeleteByOrder().thenAnswer(
        (_) async => const Left(FakeFailure('failure')),
      );

      final result = await repository.update(batmanOrder);

      expect(
        result.getLeft().toNullable()?.message,
        'failure',
      );
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to create orderProducts SHOULD return Failure', () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()..remove('products'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockDeleteByOrder().thenAnswer((_) async => const Right(null));
      mockCreate().thenAnswer(
        (_) async => const Left(FakeFailure('create failure')),
      );

      final result = await repository.update(batmanOrder);

      expect(
        result.getLeft().toNullable()?.message,
        'create failure',
      );
      verify(() => database.insideTransaction(any()));
    });

    testExceptionsOnUpdate(
      () => repository,
      () {
        mockTransaction<Either<Failure, void>>().thenAnswer(executeTransaction);
        return database;
      },
      batmanOrder,
    );
  });
}

final cakeOrderProductEntity = OrderProductEntity.fromModels(
  batmanOrder,
  cakeOrderProduct,
);
final cakeOrderProductEntityWithId = OrderProductEntity.fromModels(
  batmanOrder,
  cakeOrderProduct,
  id: 1,
);
final iceCreamOrderProductEntity = OrderProductEntity.fromModels(
  batmanOrder,
  iceCreamOrderProduct,
);
final iceCreamOrderProductEntityWithId = OrderProductEntity.fromModels(
  batmanOrder,
  iceCreamOrderProduct,
  id: 2,
);

class FakeOrderProductEntity extends Fake implements OrderProductEntity {}
