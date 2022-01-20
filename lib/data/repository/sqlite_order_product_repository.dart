import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';
import '../../database/database.dart';
import '../../database/sqlite/sqlite.dart';
import '../../domain/domain.dart';

part 'sqlite_order_product_repository.g.dart';

abstract class OrderProductRepository
    extends Repository<OrderProductEntity, int> {
  Future<fp.Either<Failure, int?>> findId(
      int orderId, OrderProduct orderProduct);

  Future<fp.Either<Failure, List<OrderProductEntity>>> findByOrder(int orderId);

  Future<fp.Either<Failure, void>> deleteByOrder(int orderId);
}

class SQLiteOrderProductRepository extends SQLiteRepository<OrderProductEntity>
    implements OrderProductRepository {
  SQLiteOrderProductRepository(SQLiteDatabase database)
      : super(
          'orderProducts',
          'id',
          database,
          fromMap: (map) => OrderProductEntity.fromJson(map),
          toMap: (e) => e.toJson(),
        );

  @override
  Future<fp.Either<Failure, void>> deleteByOrder(int orderId) async {
    try {
      await database.delete(table: tableName, where: {'orderId': orderId});
      return const fp.Right(null);
    } on DatabaseException catch (e) {
      return fp.Left(
          DatabaseFailure(SQLiteRepository.couldNotDeleteMessage, e));
    }
  }

  @override
  Future<fp.Either<Failure, List<OrderProductEntity>>> findByOrder(
      int orderId) async {
    try {
      final result = await database.query(table: tableName, columns: [
        'id',
        'orderId',
        'productId',
        'quantity'
      ], where: {
        'orderId': orderId,
      });
      return fp.Right(result.map(fromMap).toList());
    } on DatabaseException catch (e) {
      return fp.Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }

  @override
  Future<fp.Either<Failure, int?>> findId(
    int orderId,
    OrderProduct orderProduct,
  ) async {
    try {
      final result = await database.query(table: tableName, columns: [
        'id'
      ], where: {
        'orderId': orderId,
        'productId': orderProduct.id,
      });
      if (result.isNotEmpty) {
        return fp.Right(result[0]['id']);
      }
      return const fp.Right(null);
    } on DatabaseException catch (e) {
      return fp.Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }
}

@JsonSerializable()
class OrderProductEntity extends Equatable implements Entity<int> {
  @override
  final int? id;
  final int orderId;
  final int productId;
  final double quantity;

  const OrderProductEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
  });

  factory OrderProductEntity.fromModels(
    Order order,
    OrderProduct orderProduct, {
    int? id,
  }) {
    return OrderProductEntity(
      id: id,
      orderId: order.id!,
      productId: orderProduct.id,
      quantity: orderProduct.quantity,
    );
  }

  factory OrderProductEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderProductEntityFromJson(json);

  OrderProduct toOrderProduct() => OrderProduct(
        id: productId,
        quantity: quantity,
      );

  Map<String, dynamic> toJson() => _$OrderProductEntityToJson(this);

  @override
  List<Object?> get props => [id, orderId, productId, quantity];
}
