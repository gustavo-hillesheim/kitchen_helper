import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/sqlite/sqlite_database.dart';

import '../failure.dart';
import '../repository.dart';

class SQLiteRepository<T> extends Repository<T, int> {
  final String tableName;
  final SQLiteDatabase database;
  final Map<String, dynamic> Function(T) toMap;
  final T Function(Map<String, dynamic>) fromMap;

  SQLiteRepository(
    this.tableName,
    this.database, {
    required this.toMap,
    required this.fromMap,
  });

  @override
  Future<Either<Failure, int>> create(T entity) async {
    return Right(await database.insert(tableName, toMap(entity)));
  }

  @override
  Future<Either<Failure, void>> deleteById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<T>>> findAll() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, T?>> findById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, T>> update(T entity) {
    throw UnimplementedError();
  }
}
