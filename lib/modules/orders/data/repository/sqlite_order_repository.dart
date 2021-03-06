import 'package:fpdart/fpdart.dart' hide Order;
import 'package:sqflite/sqflite.dart';

import '../../../../database/sqlite/query_operators.dart';
import '../../../../database/sqlite/where.dart';
import '../../../../core/core.dart';
import '../../../../database/sqlite/sqlite.dart';
import '../../../../extensions.dart';
import '../../domain/domain.dart';
import '../../../recipes/domain/domain.dart';
import 'sqlite_order_discount_repository.dart';
import 'sqlite_order_product_repository.dart';

class SQLiteOrderRepository extends SQLiteRepository<Order>
    implements OrderRepository {
  static const couldNotGetOrderProductsMessage =
      'Não foi possível encontrar os produtos do pedido';

  final RecipeRepository recipeRepository;
  final OrderProductRepository orderProductRepository;
  final OrderDiscountRepository orderDiscountRepository;

  SQLiteOrderRepository(
    SQLiteDatabase database,
    this.recipeRepository,
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
      final where = filter != null
          ? Where.fromMap(_filterToWhereMap(filter), tableName: 'o')
          : null;
      final result = await database.rawQuery(
        '''
      SELECT o.id id, coalesce(c.name, 'Sem cliente') clientName, coalesce(ca.identifier, 'Sem endereço') clientAddress,
        o.deliveryDate deliveryDate, o.status status,
        (SELECT SUM(op.quantity / r.quantitySold * r.price) FROM orderProducts op INNER JOIN recipes r ON r.id = op.productId WHERE op.orderId = o.id) basePrice, 
        (SELECT SUM(d.value) FROM orderDiscounts d WHERE o.id = d.orderId AND d.type = 'fixed') fixedDiscount, 
        (SELECT SUM(d.value) FROM orderDiscounts d WHERE o.id = d.orderId AND d.type = 'percentage') percentageDiscount
      FROM orders o
      LEFT JOIN clients c ON c.id = o.clientId
      LEFT JOIN clientAddresses ca ON ca.id = o.addressId AND ca.clientId = c.id
      ${where?.where?.isNotEmpty ?? false ? 'WHERE ${where!.where}' : ''}
      GROUP BY o.id
      ORDER BY o.deliveryDate
      ''',
        where?.whereArgs,
      );
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
    if (filter.clientId != null) {
      where['clientId'] = filter.clientId;
    }
    final orderDateFilters = [];
    if (filter.orderDateStart != null) {
      orderDateFilters
          .add(GreaterOrEqualThan(filter.orderDateStart!.toIso8601String()));
    }
    if (filter.orderDateEnd != null) {
      orderDateFilters
          .add(LowerOrEqualThan(filter.orderDateEnd!.toIso8601String()));
    }
    if (orderDateFilters.isNotEmpty) {
      where['orderDate'] = orderDateFilters;
    }
    final deliveryDateFilters = [];
    if (filter.deliveryDateStart != null) {
      deliveryDateFilters
          .add(GreaterOrEqualThan(filter.deliveryDateStart!.toIso8601String()));
    }
    if (filter.deliveryDateEnd != null) {
      deliveryDateFilters
          .add(LowerOrEqualThan(filter.deliveryDateEnd!.toIso8601String()));
    }
    if (deliveryDateFilters.isNotEmpty) {
      where['deliveryDate'] = deliveryDateFilters;
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
    return _getProducts(order.id!).onRightThen(
      (products) => Right(order.copyWith(products: products)),
    );
  }

  Future<Either<Failure, List<OrderProduct>>> _getProducts(int orderId) async {
    return orderProductRepository
        .findByOrder(orderId)
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
    return _getDiscounts(order.id!).onRightThen(
      (discounts) => Right(order.copyWith(discounts: discounts)),
    );
  }

  Future<Either<Failure, List<Discount>>> _getDiscounts(int orderId) async {
    return orderDiscountRepository
        .findByOrder(orderId)
        .onRightThen((discountEntities) {
      final discounts =
          discountEntities.map((e) => e.toDiscount()).toList(growable: false);
      return Right(discounts);
    });
  }

  @override
  Future<Either<Failure, EditingOrderDto?>> findEditingDtoById(int id) async {
    try {
      final exists = await database.exists(tableName, idColumn, id);
      if (!exists) {
        return const Right(null);
      }
      final orderData =
          Map<String, dynamic>.from(await _getEditingOrderData(id));
      final discounts = await _getDiscounts(id).throwOnFailure();
      final editingProducts = await _getEditingProducts(id);
      orderData['discounts'] = discounts.map((d) => d.toJson()).toList();
      orderData['products'] = editingProducts;
      return Right(EditingOrderDto.fromJson(orderData));
    } on Failure catch (f) {
      return Left(f);
    }
  }

  Future<Map<String, dynamic>> _getEditingOrderData(int id) async {
    return (await database.rawQuery('''
SELECT o.id id, o.clientId clientId, c.name clientName, o.contactId contactId, 
  cc.contact clientContact, o.addressId addressId, ca.identifier clientAddress, 
  o.orderDate orderDate, o.deliveryDate deliveryDate, o.status status
FROM orders o
LEFT JOIN clients c ON c.id = o.clientId
LEFT JOIN clientContacts cc ON c.id = cc.clientId AND cc.id = o.contactId
LEFT JOIN clientAddresses ca ON c.id = ca.clientId AND ca.id = o.addressId
WHERE o.id = ?
''', [id])).first;
  }

  Future<List<Map<String, dynamic>>> _getEditingProducts(int orderId) async {
    try {
      final queryResult = await database.rawQuery('''
SELECT op.productId id, r.name name, r.measurementUnit measurementUnit, 
  op.quantity quantity, (r.price / r.quantitySold * op.quantity) price
FROM orderProducts op
INNER JOIN recipes r ON op.productId = r.id
WHERE op.orderId = ?
''', [orderId]);
      final editingProducts = <Map<String, dynamic>>[];
      for (final row in queryResult) {
        final data = Map<String, dynamic>.from(row);
        final cost = await recipeRepository
            .getCost(data['id'], quantity: data['quantity'])
            .throwOnFailure();
        data['cost'] = cost;
        editingProducts.add(data);
      }
      return editingProducts;
    } on DatabaseException catch (e) {
      throw DatabaseFailure(couldNotGetOrderProductsMessage, e);
    }
  }
}
