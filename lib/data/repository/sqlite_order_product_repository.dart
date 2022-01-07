import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';
import '../../database/database.dart';
import '../../database/sqlite/sqlite.dart';
import '../../domain/domain.dart';

part 'sqlite_order_product_repository.g.dart';

abstract class OrderProductRepository
    extends Repository<OrderProductEntity, int> {
  Future<Either<Failure, int?>> findId(int orderId, OrderProduct orderProduct);

  Future<Either<Failure, List<OrderProductEntity>>> findByOrder(int orderId);

  Future<Either<Failure, void>> deleteByOrder(int orderId);
}

class SQLiteOrderProductRepository extends SQLiteRepository<OrderProductEntity>
    implements OrderProductRepository {
  SQLiteOrderProductRepository(SQLiteDatabase database)
      : super(
          'order_products',
          'id',
          database,
          fromMap: (map) => OrderProductEntity.fromJson(map),
          toMap: (e) => e.toJson(),
        );

  @override
  Future<Either<Failure, void>> deleteByOrder(int orderId) async {
    try {
      await database.delete(table: tableName, where: {'orderId': orderId});
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotDeleteMessage, e));
    }
  }

  @override
  Future<Either<Failure, List<OrderProductEntity>>> findByOrder(
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
      return Right(result.map(fromMap).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }

  @override
  Future<Either<Failure, int?>> findId(
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
        return Right(result[0]['id']);
      }
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }
}

@JsonSerializable()
class OrderProductEntity extends Equatable implements Entity<int> {
  @override
  final int id;
  final int orderId;
  final int productId;
  final double quantity;

  const OrderProductEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
  });

  factory OrderProductEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderProductEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OrderProductEntityToJson(this);

  @override
  List<Object?> get props => [id, orderId, productId, quantity];
}
