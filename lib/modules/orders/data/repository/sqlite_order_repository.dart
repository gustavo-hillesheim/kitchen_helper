import 'package:fpdart/fpdart.dart' hide Order;
import 'package:sqflite/sqflite.dart';

import '../../../../core/core.dart';
import '../../../../database/sqlite/sqlite.dart';
import '../../../../extensions.dart';
import '../../domain/domain.dart';
import 'sqlite_order_discount_repository.dart';
import 'sqlite_order_product_repository.dart';

class SQLiteOrderRepository extends SQLiteRepository<Order>
    implements OrderRepository {
  final OrderProductRepository orderProductRepository;
  final OrderDiscountRepository orderDiscountRepository;

  SQLiteOrderRepository(
    SQLiteDatabase database,
    this.orderProductRepository,
    this.orderDiscountRepository,
  ) : super(
          'orders',
          'id',
          database,
          fromMap: (map) {
            map = Map.from(map);
            map['products'] = [];
            map['discounts'] = [];
            return Order.fromJson(map);
          },
          toMap: (order) {
            final map = order.toJson();
            map.remove('products');
            map.remove('discounts');
            return map;
          },
        );

  @override
  Future<Either<Failure, Order?>> findById(int id) {
    return super.findById(id).onRightThen((order) async {
      if (order != null) {
        return _withProducts(order)
            .onRightThen((order) => _withDiscounts(order));
      }
      return Right(order);
    });
  }

  @override
  Future<Either<Failure, List<Order>>> findAll({OrdersFilter? filter}) async {
    try {
      final where = filter != null ? _filterToWhereMap(filter) : null;
      final entities = await database.findAll(tableName, where: where);
      final ordersResult = await Future.wait(entities
          .map(fromMap)
          .toList(growable: false)
          .map((order) => _withDiscounts(order)
              .onRightThen((order) => _withProducts(order))));
      return ordersResult.asEitherList();
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  @override
  Future<Either<Failure, List<ListingOrderDto>>> findAllListing(
      {OrdersFilter? filter}) async {
    try {
      final where = filter != null ? _filterToWhereMap(filter) : null;
      final result = await database.rawQuery('''
      SELECT o.id id, o.clientName clientName, o.clientAddress clientAddress,
        o.deliveryDate deliveryDate, o.status status,
        (r.quantitySold / r.quantityProduced * r.price * op.quantity) basePrice, 
        sum(case when d.type = 'fixed' then d.value else 0 end) fixedDiscount, 
        sum(case when d.type = 'percentage' then d.value else 0 end) 
        percentageDiscount
      FROM orders o
      LEFT JOIN orderProducts op ON o.id = op.orderId
      LEFT JOIN recipes r ON r.id = op.productId
      LEFT JOIN orderDiscounts d ON o.id = d.orderId
      ${where?.isNotEmpty ?? false ? 'WHERE ${where!.keys.map((key) => '$key = ?').join(' AND ')}' : ''}
      GROUP BY o.id
      ORDER BY o.deliveryDate
      ''', where?.values.toList());
      final dtos = result.map((json) {
        // Creates muttable map
        json = Map.from(json);
        final basePrice = json['basePrice'] ?? 0;
        final fixedDiscount = json['fixedDiscount'] ?? 0;
        final percentageDiscount = json['percentageDiscount'] ?? 0;
        json['price'] =
            basePrice - fixedDiscount - percentageDiscount / 100 * basePrice;
        return ListingOrderDto.fromJson(json);
      }).toList();
      return Right(dtos);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
    }
  }

  @override
  Future<Either<Failure, List<ListingOrderProductDto>>>
      findAllOrderProductsListing(int orderId) async {
    try {
      final result = await database.rawQuery('''
    SELECT r.name name, r.measurementUnit measurementUnit, op.quantity quantity
    FROM orderProducts op
    INNER JOIN recipes r ON r.id = op.productId
    WHERE op.orderId = ?
    ''', [orderId]);
      return Right(result.map(ListingOrderProductDto.fromJson).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotFindAllMessage, e));
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
  Future<Either<Failure, void>> deleteById(int id) {
    return database.insideTransaction(
      () => super
          .deleteById(id)
          .onRightThen((_) => orderDiscountRepository.deleteByOrder(id))
          .onRightThen((_) => orderProductRepository.deleteByOrder(id)),
    );
  }

  @override
  Future<Either<Failure, void>> update(Order order) {
    return database.insideTransaction(
      () => super
          .update(order)
          .onRightThen((_) => orderDiscountRepository.deleteByOrder(order.id!))
          .onRightThen((_) => orderProductRepository.deleteByOrder(order.id!))
          .onRightThen((_) => _createDiscounts(order))
          .onRightThen((_) => _createProducts(order))
          .onRightThen((_) => const Right(null)),
    );
  }

  @override
  Future<Either<Failure, int>> create(Order order) {
    return database.insideTransaction(
      () => super.create(order).onRightThen((orderId) {
        order = order.copyWith(id: orderId);
        return _createProducts(order)
            .onRightThen((_) => _createDiscounts(order))
            .onRightThen((_) => Right(orderId));
      }),
    );
  }

  Future<Either<Failure, List<int>>> _createProducts(Order order) async {
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

  Future<Either<Failure, Order>> _withProducts(Order order) async {
    return _getProducts(order).onRightThen(
      (products) => Right(order.copyWith(products: products)),
    );
  }

  Future<Either<Failure, List<OrderProduct>>> _getProducts(Order order) async {
    return orderProductRepository
        .findByOrder(order.id!)
        .onRightThen((productsEntities) {
      final products = productsEntities
          .map((e) => e.toOrderProduct())
          .toList(growable: false);
      return Right(products);
    });
  }

  Future<Either<Failure, List<int>>> _createDiscounts(Order order) async {
    final discountEntities = _createDiscountEntities(order);
    final futures = discountEntities
        .map((discount) => orderDiscountRepository.create(discount));
    final results = await Future.wait(futures);
    return results.asEitherList();
  }

  List<OrderDiscountEntity> _createDiscountEntities(Order order) {
    return order.discounts
        .map((d) => OrderDiscountEntity.fromModels(order, d))
        .toList();
  }

  Future<Either<Failure, Order>> _withDiscounts(Order order) async {
    return _getDiscounts(order).onRightThen(
      (discounts) => Right(order.copyWith(discounts: discounts)),
    );
  }

  Future<Either<Failure, List<Discount>>> _getDiscounts(Order order) async {
    return orderDiscountRepository
        .findByOrder(order.id!)
        .onRightThen((discountEntities) {
      final discounts =
          discountEntities.map((e) => e.toDiscount()).toList(growable: false);
      return Right(discounts);
    });
  }
}