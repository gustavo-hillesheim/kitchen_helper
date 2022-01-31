import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:json_annotation/json_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/core.dart';
import '../../../../database/database.dart';
import '../../../../database/sqlite/sqlite.dart';
import '../../domain/domain.dart';

part 'sqlite_order_discount_repository.g.dart';

abstract class OrderDiscountRepository
    extends Repository<OrderDiscountEntity, int> {
  Future<Either<Failure, int?>> findId(int orderId, Discount discount);

  Future<Either<Failure, List<OrderDiscountEntity>>> findByOrder(int orderId);

  Future<Either<Failure, void>> deleteByOrder(int orderId);
}

class SQLiteOrderDiscountRepository
    extends SQLiteRepository<OrderDiscountEntity>
    implements OrderDiscountRepository {
  SQLiteOrderDiscountRepository(SQLiteDatabase database)
      : super(
          'orderDiscounts',
          'id',
          database,
          toMap: (d) => d.toJson(),
          fromMap: (map) => OrderDiscountEntity.fromJson(map),
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
  Future<Either<Failure, List<OrderDiscountEntity>>> findByOrder(
      int orderId) async {
    try {
      final result = await database.query(table: tableName, columns: [
        'id',
        'orderId',
        'reason',
        'type',
        'value'
      ], where: {
        'orderId': orderId,
      });
      return Right(result.map(fromMap).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(SQLiteRepository.couldNotQueryMessage, e));
    }
  }

  @override
  Future<Either<Failure, int?>> findId(int orderId, Discount discount) async {
    try {
      final result = await database.query(table: tableName, columns: [
        'id'
      ], where: {
        'orderId': orderId,
        'reason': discount.reason,
        'type': discount.type.name,
        'value': discount.value,
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
class OrderDiscountEntity extends Equatable implements Entity<int> {
  @override
  final int? id;
  final int orderId;
  final String reason;
  final DiscountType type;
  final double value;

  const OrderDiscountEntity({
    this.id,
    required this.orderId,
    required this.reason,
    required this.type,
    required this.value,
  });

  factory OrderDiscountEntity.fromModels(Order order, Discount discount) {
    return OrderDiscountEntity(
      orderId: order.id!,
      reason: discount.reason,
      type: discount.type,
      value: discount.value,
    );
  }

  factory OrderDiscountEntity.fromJson(Map<String, dynamic> json) =>
      _$OrderDiscountEntityFromJson(json);

  Discount toDiscount() => Discount(
        reason: reason,
        type: type,
        value: value,
      );

  Map<String, dynamic> toJson() => _$OrderDiscountEntityToJson(this);

  @override
  List<Object?> get props => [id, orderId, reason, type, value];
}
