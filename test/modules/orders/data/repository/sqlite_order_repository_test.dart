import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/orders/data/repository/sqlite_order_discount_repository.dart';
import 'package:kitchen_helper/modules/orders/data/repository/sqlite_order_product_repository.dart';
import 'package:kitchen_helper/modules/orders/data/repository/sqlite_order_repository.dart';
import 'package:kitchen_helper/modules/orders/domain/domain.dart';
import 'package:kitchen_helper/modules/recipes/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';
import '../../../../sqlite_repository_tests.dart';

void main() {
  late SQLiteOrderRepository repository;
  late OrderProductRepository orderProductRepository;
  late OrderDiscountRepository orderDiscountRepository;
  late RecipeRepository recipeRepository;
  late SQLiteDatabase database;
  const tableName = 'orders';
  const idColumn = 'id';

  setUp(() {
    registerFallbackValue(FakeOrderProductEntity());
    registerFallbackValue(FakeOrderDiscountEntity());
    database = SQLiteDatabaseMock();
    orderProductRepository = OrderProductRepositoryMock();
    orderDiscountRepository = OrderDiscountRepositoryMock();
    recipeRepository = RecipeRepositoryMock();
    repository = SQLiteOrderRepository(database, recipeRepository,
        orderProductRepository, orderDiscountRepository);
  });

  test('toMap SHOULD remove products field', () {
    final map = repository.toMap(spidermanOrder);
    expect(
        map,
        spidermanOrder.toJson()
          ..remove('products')
          ..remove('discounts'));
  });

  test('fromMap SHOULD set products field to empty', () {
    final order = repository.fromMap(spidermanOrder.toJson());
    expect(order, spidermanOrder.copyWith(products: [], discounts: []));
  });

  When<Future<Either<Failure, List<OrderProductEntity>>>>
      mockFindProductsByOrder() {
    return when(() => orderProductRepository.findByOrder(any()));
  }

  When<Future<Either<Failure, List<OrderDiscountEntity>>>>
      mockFindDiscountsByOrder() {
    return when(() => orderDiscountRepository.findByOrder(any()));
  }

  When<Future<Either<Failure, void>>> mockDeleteProductsByOrder() {
    return when(() => orderProductRepository.deleteByOrder(any()));
  }

  When<Future<Either<Failure, void>>> mockDeleteDiscountsByOrder() {
    return when(() => orderDiscountRepository.deleteByOrder(any()));
  }

  When<Future<Either<Failure, int>>> mockCreateProduct() {
    return when(() => orderProductRepository.create(any()));
  }

  When<Future<Either<Failure, int>>> mockCreateDiscount() {
    return when(() => orderDiscountRepository.create(any()));
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

    test('WHEN finds order SHOULD fill products and discounts', () async {
      mockFindById().thenAnswer((_) async => repository.toMap(batmanOrder));
      mockFindDiscountsByOrder()
          .thenAnswer((_) async => Right([batmanDiscountEntity]));
      mockFindProductsByOrder().thenAnswer(
        (_) async => Right([
          cakeOrderProductEntityWithId,
          iceCreamOrderProductEntityWithId,
        ]),
      );

      final result = await repository.findById(batmanOrder.id!);

      expect(result.getRight().toNullable(), batmanOrder);
      verify(() => database.findById(tableName, idColumn, batmanOrder.id!));
      verify(() => orderProductRepository.findByOrder(batmanOrder.id!));
      verify(() => orderDiscountRepository.findByOrder(batmanOrder.id!));
    });

    test('WHEN finds no order SHOULD not fill products', () async {
      mockFindById().thenAnswer((_) async => null);

      final result = await repository.findById(batmanOrder.id!);

      expect(result.getRight().toNullable(), isNull);
      verify(() => database.findById(tableName, idColumn, batmanOrder.id!));
      verifyNever(() => orderProductRepository.findByOrder(any()));
    });

    test('WHEN orderProductRepository returns Failure SHOULD return Failure',
        () async {
      final failure = FakeFailure('failure');
      mockFindById().thenAnswer((_) async => repository.toMap(batmanOrder));
      mockFindProductsByOrder().thenAnswer((_) async => Left(failure));

      final result = await repository.findById(batmanOrder.id!);

      expect(result.getLeft().toNullable(), failure);
    });

    test('WHEN orderDiscountRepository returns Failure SHOULD return Failure',
        () async {
      final failure = FakeFailure('failure');
      mockFindById().thenAnswer((_) async => repository.toMap(batmanOrder));
      mockFindProductsByOrder().thenAnswer((_) async => const Right([]));
      mockFindDiscountsByOrder().thenAnswer((_) async => Left(failure));

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
      return when(() => database.findAll(any(), where: any(named: 'where')));
    }

    test('WHEN finds orders SHOULD fill products', () async {
      mockFindAll().thenAnswer((_) async => [
            repository.toMap(spidermanOrderWithId),
            repository.toMap(batmanOrder),
          ]);
      mockFindDiscountsByOrder().thenAnswer((invocation) async {
        final orderId = invocation.positionalArguments[0];
        return Right({
          spidermanOrderWithId.id!: [spiderManDiscountEntity],
          batmanOrder.id!: [batmanDiscountEntity],
        }[orderId]!);
      });
      mockFindProductsByOrder().thenAnswer((invocation) async {
        final orderId = invocation.positionalArguments[0];
        return Right({
          spidermanOrderWithId.id!: [cakeOrderProductEntityWithId],
          batmanOrder.id!: [
            cakeOrderProductEntityWithId,
            iceCreamOrderProductEntityWithId
          ],
        }[orderId]!);
      });

      final result = await repository.findAll();

      expect(
          result.getRight().toNullable(), [spidermanOrderWithId, batmanOrder]);
      verify(() => database.findAll(tableName));
      verify(() => orderProductRepository.findByOrder(batmanOrder.id!));
      verify(
          () => orderProductRepository.findByOrder(spidermanOrderWithId.id!));
      verify(() => orderDiscountRepository.findByOrder(batmanOrder.id!));
      verify(
          () => orderDiscountRepository.findByOrder(spidermanOrderWithId.id!));
    });

    test('WHEN informs filter SHOULD call database correctly', () async {
      mockFindAll().thenAnswer((_) async => []);
      await repository.findAll(
        filter: const OrdersFilter(
          status: OrderStatus.delivered,
        ),
      );
      verify(() => database.findAll(tableName, where: {
            'status': 'delivered',
          }));
    });

    test('WHEN finds no order SHOULD not fill products', () async {
      mockFindAll().thenAnswer((_) async => []);

      final result = await repository.findAll();

      expect(result.getRight().toNullable(), []);
      verify(() => database.findAll(tableName));
      verifyNever(() => orderProductRepository.findByOrder(any()));
      verifyNever(() => orderDiscountRepository.findByOrder(any()));
    });

    test('WHEN orderProductRepository returns Failure SHOULD return Failure',
        () async {
      final failure = FakeFailure('failure');
      mockFindAll().thenAnswer(
        (_) async => [repository.toMap(batmanOrder)],
      );
      mockFindDiscountsByOrder().thenAnswer((_) async => const Right([]));
      mockFindProductsByOrder().thenAnswer((_) async => Left(failure));

      final result = await repository.findAll();

      expect(result.getLeft().toNullable(), failure);
      verify(() => database.findAll(tableName));
      verify(
        () => orderProductRepository.findByOrder(batmanOrder.id!),
      );
    });

    test('WHEN orderDiscountRepository returns Failure SHOULD return Failure',
        () async {
      final failure = FakeFailure('failure');
      mockFindAll().thenAnswer(
        (_) async => [repository.toMap(batmanOrder)],
      );
      mockFindDiscountsByOrder().thenAnswer((_) async => Left(failure));

      final result = await repository.findAll();

      expect(result.getLeft().toNullable(), failure);
      verify(() => database.findAll(tableName));
      verify(() => orderDiscountRepository.findByOrder(batmanOrder.id!));
      verifyNever(() => orderProductRepository.findByOrder(batmanOrder.id!));
    });

    testExceptionsOnFindAll(
      () => repository,
      () => database,
      tableName,
      verifications: () {
        verifyNever(() => orderDiscountRepository.findByOrder(any()));
        verifyNever(() => orderProductRepository.findByOrder(any()));
      },
    );
  });

  group('deleteById', () {
    When<Future<void>> mockDeleteById() {
      return when(() => database.deleteById(any(), any(), any()));
    }

    test('WHEN deletes order SHOULD delete products and discounts', () async {
      mockDeleteById().thenAnswer((_) async {});
      mockDeleteDiscountsByOrder().thenAnswer((_) async => const Right(null));
      mockDeleteProductsByOrder().thenAnswer((_) async => const Right(null));
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.deleteById(tableName, idColumn, batmanOrder.id!));
        verify(
          () => orderDiscountRepository.deleteByOrder(batmanOrder.id!),
        );
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
      mockDeleteDiscountsByOrder().thenAnswer((_) async => const Right(null));
      mockDeleteProductsByOrder().thenAnswer(
        (_) async => Left(FakeFailure('failure')),
      );
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.deleteById(tableName, idColumn, batmanOrder.id!));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderDiscountRepository.deleteByOrder(batmanOrder.id!));
        return result;
      });

      final result = await repository.deleteById(batmanOrder.id!);

      expect(result.getLeft().toNullable()?.message, 'failure');
      verify(() => database.insideTransaction(any()));
    });

    test(
        'WHEN orderDiscountRepository returns Failure '
        'SHOULD return Failure', () async {
      mockDeleteById().thenAnswer((_) async {});
      mockDeleteDiscountsByOrder()
          .thenAnswer((_) async => Left(FakeFailure('failure')));
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.deleteById(tableName, idColumn, batmanOrder.id!));
        verifyNever(
            () => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderDiscountRepository.deleteByOrder(batmanOrder.id!));
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

    test('WHEN creates order SHOULD create products and discounts', () async {
      final productIds = [
        iceCreamOrderProductEntityWithId.id!,
        cakeOrderProductEntityWithId.id!
      ];
      mockTransaction<Either<Failure, int>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.insert(tableName, repository.toMap(batmanOrder)));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        verify(() => orderDiscountRepository.create(batmanDiscountEntity));
        return result;
      });
      mockInsert().thenAnswer((_) async => batmanOrder.id!);
      mockCreateProduct()
          .thenAnswer((_) async => Right(productIds.removeLast()));
      mockCreateDiscount().thenAnswer((_) async => const Right(1));

      final result = await repository.create(batmanOrder);

      expect(result.getRight().toNullable(), batmanOrder.id!);
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to create order SHOULD NOT create products nor discounts',
        () async {
      mockTransaction<Either<Failure, int>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.insert(tableName, repository.toMap(batmanOrder)));
        verifyNever(() => orderProductRepository.create(any()));
        verifyNever(() => orderDiscountRepository.create(any()));
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
      mockCreateProduct().thenAnswer(
        (_) async => Left(FakeFailure('failure')),
      );

      final result = await repository.create(batmanOrder);

      expect(result.getLeft().toNullable()?.message, 'failure');
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN orderDiscountRepository retuns Failure SHOULD return Failure',
        () async {
      mockTransaction<Either<Failure, int>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.insert(tableName, repository.toMap(batmanOrder)));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        verify(() => orderDiscountRepository.create(batmanDiscountEntity));
        return result;
      });
      mockInsert().thenAnswer((_) async => batmanOrder.id!);
      mockCreateProduct().thenAnswer((_) async => const Right(1));
      mockCreateDiscount()
          .thenAnswer((_) async => Left(FakeFailure('failure')));

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

    test('WHEN updates order SHOULD recreate products and discounts', () async {
      final ids = [
        iceCreamOrderProductEntityWithId.id!,
        cakeOrderProductEntityWithId.id!,
      ];
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()
                ..remove('products')
                ..remove('discounts'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderDiscountRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        verify(() => orderDiscountRepository.create(batmanDiscountEntity));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockDeleteDiscountsByOrder().thenAnswer((_) async => const Right(null));
      mockDeleteProductsByOrder().thenAnswer((_) async => const Right(null));
      mockCreateProduct().thenAnswer((_) async => Right(ids.removeLast()));
      mockCreateDiscount().thenAnswer((_) async => Right(ids.last));

      final result = await repository.update(batmanOrder);

      expect(result.isRight(), true);
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to update order SHOULD not recreate products or discounts',
        () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()
                ..remove('products')
                ..remove('discounts'),
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

    test('WHEN fails to delete products SHOULD not recreate them', () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()
                ..remove('products')
                ..remove('discounts'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verifyNever(() => orderProductRepository.create(any()));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockDeleteProductsByOrder().thenAnswer(
        (_) async => Left(FakeFailure('failure')),
      );
      mockDeleteDiscountsByOrder().thenAnswer((_) async => const Right(null));

      final result = await repository.update(batmanOrder);

      expect(
        result.getLeft().toNullable()?.message,
        'failure',
      );
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to delete discounts SHOULD not recreate them', () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()
                ..remove('products')
                ..remove('discounts'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderDiscountRepository.deleteByOrder(batmanOrder.id!));
        verifyNever(() => orderProductRepository.deleteByOrder(any()));
        verifyNever(() => orderProductRepository.create(any()));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockDeleteDiscountsByOrder()
          .thenAnswer((_) async => Left(FakeFailure('failure')));

      final result = await repository.update(batmanOrder);

      expect(
        result.getLeft().toNullable()?.message,
        'failure',
      );
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to create products SHOULD return Failure', () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()
                ..remove('products')
                ..remove('discounts'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderDiscountRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderProductRepository.create(cakeOrderProductEntity));
        verify(() => orderProductRepository.create(iceCreamOrderProductEntity));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockDeleteProductsByOrder().thenAnswer((_) async => const Right(null));
      mockCreateDiscount().thenAnswer((_) async => const Right(1));
      mockDeleteDiscountsByOrder().thenAnswer((_) async => const Right(null));
      mockCreateProduct().thenAnswer(
        (_) async => Left(FakeFailure('create failure')),
      );

      final result = await repository.update(batmanOrder);

      expect(
        result.getLeft().toNullable()?.message,
        'create failure',
      );
      verify(() => database.insideTransaction(any()));
    });

    test('WHEN fails to create discounts SHOULD return Failure', () async {
      mockTransaction<Either<Failure, void>>().thenAnswer((invocation) async {
        final result = await executeTransaction(invocation);
        verify(() => database.update(
              tableName,
              batmanOrder.toJson()
                ..remove('products')
                ..remove('discounts'),
              idColumn,
              batmanOrder.id!,
            ));
        verify(() => orderDiscountRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderProductRepository.deleteByOrder(batmanOrder.id!));
        verify(() => orderDiscountRepository.create(batmanDiscountEntity));
        verifyNever(() => orderProductRepository.create(any()));
        return result;
      });
      mockUpdate().thenAnswer((_) async {});
      mockCreateDiscount()
          .thenAnswer((_) async => Left(FakeFailure('create failure')));
      mockDeleteDiscountsByOrder().thenAnswer((_) async => const Right(null));
      mockDeleteProductsByOrder().thenAnswer((_) async => const Right(null));

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

  group('findAllListing', () {
    test('WHEN database has records SHOULD return DTOs', () async {
      when(() => database.rawQuery(any(), any())).thenAnswer((_) async => [
            {
              'id': 1,
              'clientName': 'Test client',
              'clientAddress': 'Test Address',
              'deliveryDate': '2022-01-01 12:30',
              'basePrice': 50,
              'fixedDiscount': 5,
              'percentageDiscount': 10,
              'status': 'delivered',
            }
          ]);

      final result = await repository.findAllListing(
          filter: const OrdersFilter(status: OrderStatus.delivered));

      expect(result.getRight().toNullable(), [
        ListingOrderDto(
          id: 1,
          clientName: 'Test client',
          clientAddress: 'Test Address',
          deliveryDate: DateTime(2022, 1, 1, 12, 30),
          price: 40,
          status: OrderStatus.delivered,
        ),
      ]);
      verify(() => database.rawQuery(
            any(that: contains('WHERE status = ?')),
            ['delivered'],
          ));
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      when(() => database.rawQuery(any()))
          .thenThrow(FakeDatabaseException('error'));

      final result = await repository.findAllListing();

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD return Failure',
        () async {
      when(() => database.rawQuery(any())).thenThrow(Exception('error'));

      try {
        await repository.findAllListing();
        fail('Should have thrown Exception');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('findAllOrderProductsListing', () {
    test('WHEN database has records SHOULD return DTOs', () async {
      when(() => database.rawQuery(any(), any())).thenAnswer((_) async => [
            {
              'name': 'Cake',
              'measurementUnit': 'units',
              'quantity': 5,
            }
          ]);

      final result = await repository.findAllOrderProductsListing(1);

      expect(result.getRight().toNullable(), [
        const ListingOrderProductDto(
          quantity: 5,
          measurementUnit: MeasurementUnit.units,
          name: 'Cake',
        ),
      ]);
    });

    test('WHEN database throws DatabaseException SHOULD return Failure',
        () async {
      when(() => database.rawQuery(any(), any()))
          .thenThrow(FakeDatabaseException('error'));

      final result = await repository.findAllOrderProductsListing(1);

      expect(
        result.getLeft().toNullable()?.message,
        SQLiteRepository.couldNotFindAllMessage,
      );
    });

    test('WHEN database throws unknown Exception SHOULD return Failure',
        () async {
      when(() => database.rawQuery(any(), any())).thenThrow(Exception('error'));

      try {
        await repository.findAllOrderProductsListing(1);
        fail('Should have thrown Exception');
      } on Exception catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });

  group('findEditingDtoById', () {
    void mockExists(int orderId, bool result) {
      when(() => database.exists(
              repository.tableName, repository.idColumn, orderId))
          .thenAnswer((_) async => result);
    }

    void mockGetEditingOrderData(int orderId, EditingOrderDto? dto) {
      when(() => database.rawQuery(any(), [orderId])).thenAnswer((_) async => [
            if (dto != null)
              dto.toJson()
                ..remove('products')
                ..remove('discounts')
          ]);
    }

    void mockFindDiscounts(
        int orderId, Either<Failure, List<OrderDiscountEntity>> result) {
      when(() => orderDiscountRepository.findByOrder(orderId))
          .thenAnswer((_) async => result);
    }

    void mockFindEditingProducts(
        int orderId, List<Map<String, dynamic>> result) {
      when(() => database.rawQuery(
              any(that: contains('FROM orderProducts op')), [orderId]))
          .thenAnswer((_) async => result);
    }

    void mockFindEditingProductsThrow(int orderId, error) {
      when(() => database.rawQuery(
              any(that: contains('FROM orderProducts op')), [orderId]))
          .thenThrow(error);
    }

    void mockQueriesOfFindEditing(int orderId, EditingOrderDto? dto) {
      mockExists(orderId, dto != null);
      if (dto != null) {
        mockGetEditingOrderData(orderId, dto);
        mockFindDiscounts(
            orderId,
            Right(dto.discounts
                .map((d) => OrderDiscountEntity(
                      orderId: orderId,
                      reason: d.reason,
                      type: d.type,
                      value: d.value,
                    ))
                .toList()));
        mockFindEditingProducts(
            orderId,
            dto.products
                .map((product) => {
                      'name': product.name,
                      'measurementUnit': product.measurementUnit.name,
                      'price': product.price,
                      'id': product.id,
                      'quantity': product.quantity,
                      'productId': product.id,
                    })
                .toList());
        for (final product in dto.products) {
          when(() => recipeRepository.getCost(product.id,
                  quantity: product.quantity))
              .thenAnswer((_) async => Right(product.cost));
        }
      }
    }

    test('WHEN database returns data SHOULD return EditingOrderDto', () async {
      mockQueriesOfFindEditing(1, editingSpidermanOrderDtoWithId);

      final result = await repository.findEditingDtoById(1);

      expect(result.getRight().toNullable(), editingSpidermanOrderDtoWithId);
    });

    test('WHEN record doesn\'t exist SHOULD return null', () async {
      mockQueriesOfFindEditing(1, null);

      final result = await repository.findEditingDtoById(1);

      expect(result.getRight().toNullable(), null);
    });

    test('WHEN has failure on getting discounts SHOULD return Failure',
        () async {
      final failure = FakeFailure('error on discounts');
      mockExists(1, true);
      mockGetEditingOrderData(1, editingSpidermanOrderDtoWithId);
      mockFindDiscounts(1, Left(failure));

      final result = await repository.findEditingDtoById(1);

      expect(result.getLeft().toNullable(), failure);
    });

    test('WHEN has error on getting products SHOULD return Failure', () async {
      final error = FakeDatabaseException('error on products');
      mockExists(1, true);
      mockGetEditingOrderData(1, editingSpidermanOrderDtoWithId);
      mockFindDiscounts(1, const Right([]));
      mockFindEditingProductsThrow(1, error);

      final result = await repository.findEditingDtoById(1);

      expect(
        result.getLeft().toNullable(),
        DatabaseFailure(
            SQLiteOrderRepository.couldNotGetOrderProductsMessage, error),
      );
    });

    test('WHEN has failure on getting product cost SHOULD return Failure',
        () async {
      final failure = FakeFailure('failure on cost');
      mockExists(1, true);
      mockGetEditingOrderData(1, editingSpidermanOrderDtoWithId);
      mockFindDiscounts(1, const Right([]));
      mockFindEditingProducts(1, [
        {
          ...editingOrderProduct(cakeOrderProduct).toJson(),
          'productId': cakeOrderProduct.id,
        }
      ]);
      when(() =>
              recipeRepository.getCost(any(), quantity: any(named: 'quantity')))
          .thenAnswer((_) async => Left(failure));

      final result = await repository.findEditingDtoById(1);

      expect(result.getLeft().toNullable(), failure);
    });
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
final batmanDiscountEntity = OrderDiscountEntity.fromModels(
  batmanOrder,
  batmanOrder.discounts[0],
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
final spiderManDiscountEntity = OrderDiscountEntity.fromModels(
  spidermanOrderWithId,
  spidermanOrderWithId.discounts[0],
);

class FakeOrderProductEntity extends Fake implements OrderProductEntity {}

class FakeOrderDiscountEntity extends Fake implements OrderDiscountEntity {}
