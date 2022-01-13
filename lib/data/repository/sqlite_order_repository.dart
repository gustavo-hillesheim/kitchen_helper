import 'package:fpdart/fpdart.dart' as fp;
import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';
import '../../database/sqlite/sqlite.dart';
import '../../domain/domain.dart';
import '../../extensions.dart';
import 'sqlite_order_product_repository.dart';

class SQLiteOrderRepository extends SQLiteRepository<Order>
    implements OrderRepository {
  final OrderProductRepository orderProductRepository;

  SQLiteOrderRepository(SQLiteDatabase database, this.orderProductRepository)
      : super(
          'orders',
          'id',
          database,
          fromMap: (map) {
            map = Map.from(map);
            map['products'] = [];
            return Order.fromJson(map);
          },
          toMap: (order) {
            final map = order.toJson();
            map.remove('products');
            return map;
          },
        );

  @override
  Future<fp.Either<Failure, Order?>> findById(int id) {
    return super.findById(id).onRightThen((order) async {
      if (order != null) {
        return _withProducts(order);
      }
      return fp.Right(order);
    });
  }

  @override
  Future<fp.Either<Failure, List<Order>>> findAll(
      {OrdersFilter? filter}) async {
    try {
      final where = filter != null ? _filterToWhereMap(filter) : null;
      final entities = await database.findAll(tableName, where: where);
      final ordersResult = entities
          .map(fromMap)
          .toList(growable: false)
          .asyncMap((order) => _withProducts(order))
          .then((orders) => orders.asEitherList());
      return ordersResult;
    } on DatabaseException catch (e) {
      return fp.Left(
          DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  Map<String, dynamic> _filterToWhereMap(OrdersFilter filter) {
    final where = <String, dynamic>{};
    if (filter.status != null) {
      where['status'] = filter.status!.name;
    }
    return where;
  }

  @override
  Future<fp.Either<Failure, void>> deleteById(int id) {
    return database.insideTransaction(
      () => super
          .deleteById(id)
          .onRightThen((_) => orderProductRepository.deleteByOrder(id)),
    );
  }

  @override
  Future<fp.Either<Failure, void>> update(Order order) {
    return database.insideTransaction(
      () => super
          .update(order)
          .onRightThen((_) => orderProductRepository.deleteByOrder(order.id!))
          .onRightThen((_) => _createProducts(order))
          .onRightThen((_) => const fp.Right(null)),
    );
  }

  @override
  Future<fp.Either<Failure, int>> create(Order order) {
    return database.insideTransaction(
      () => super.create(order).onRightThen((orderId) {
        order = order.copyWith(id: orderId);
        return _createProducts(order).onRightThen((_) => fp.Right(orderId));
      }),
    );
  }

  Future<fp.Either<Failure, List<int>>> _createProducts(Order order) async {
    final productEntities = _createProductEntities(order);
    final futures = productEntities
        .map((product) => orderProductRepository.create(product));
    final results = await Future.wait(futures);
    return results.asEitherList();
  }

  List<OrderProductEntity> _createProductEntities(Order order) {
    return order.products
        .map((product) => OrderProductEntity.fromModels(order, product))
        .toList(growable: false);
  }

  Future<fp.Either<Failure, Order>> _withProducts(Order order) async {
    return _getProducts(order).onRightThen(
      (products) => fp.Right(order.copyWith(products: products)),
    );
  }

  Future<fp.Either<Failure, List<OrderProduct>>> _getProducts(
      Order order) async {
    return orderProductRepository
        .findByOrder(order.id!)
        .onRightThen((productsEntities) {
      final products = productsEntities
          .map((e) => e.toOrderProduct())
          .toList(growable: false);
      return fp.Right(products);
    });
  }
}
