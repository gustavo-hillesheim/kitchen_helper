import 'package:fpdart/fpdart.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';
import '../../extensions.dart';
import '../database.dart';
import 'sqlite_database.dart';

class SQLiteRepository<T extends Entity<int>> extends Repository<T, int> {
  static const couldNotInsertMessage = 'Não foi possível salvar o registro';
  static const couldNotUpdateMessage = 'Não foi possível atualizar o registro';
  static const couldNotDeleteMessage =
      'Não foi possível deletar o(s) registro(s)';
  static const couldNotFindAllMessage = 'Não foi possível encontrar registros';
  static const couldNotFindMessage = 'Não foi possível encontrar o registro';
  static const canNotUpdateWithIdMessage = 'Não é possível atualizar um '
      'registro que não esteja salvo';
  static const couldNotVerifyExistenceMessage = 'Não foi possível verificar '
      'se o registro existe';
  static const couldNotQueryMessage = 'Não foi possível realizar a consulta';

  final String tableName;
  final String idColumn;
  final SQLiteDatabase database;
  final Map<String, dynamic> Function(T) toMap;
  final T Function(Map<String, dynamic>) fromMap;

  SQLiteRepository(
    this.tableName,
    this.idColumn,
    this.database, {
    required this.toMap,
    required this.fromMap,
  });

  @override
  Future<Either<Failure, int>> save(T entity) async {
    if (entity.id == null) {
      return create(entity);
    }
    return exists(entity.id!).onRightThen((exists) {
      if (exists) {
        return update(entity).onRightThen((_) => Right(entity.id!));
      }
      return create(entity);
    });
  }

  @override
  Future<Either<Failure, int>> create(T entity) async {
    try {
      final id = await database.insert(tableName, toMap(entity));
      return Right(id);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(couldNotInsertMessage, e));
    }
  }

  @override
  Future<Either<Failure, void>> update(T entity) async {
    if (entity.id == null) {
      return Left(RepositoryFailure(canNotUpdateWithIdMessage));
    }
    try {
      await database.update(tableName, toMap(entity), idColumn, entity.id!);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(couldNotUpdateMessage, e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteById(int id) async {
    try {
      await database.deleteById(tableName, idColumn, id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(couldNotDeleteMessage, e));
    }
  }

  @override
  Future<Either<Failure, List<T>>> findAll() async {
    try {
      final entities = await database.findAll(tableName);
      return Right(entities.map(fromMap).toList(growable: false));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(couldNotFindAllMessage, e));
    }
  }

  @override
  Future<Either<Failure, T?>> findById(int id) async {
    try {
      final entity = await database.findById(tableName, idColumn, id);
      return Right(entity != null ? fromMap(entity) : null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(couldNotFindMessage, e));
    }
  }

  @override
  Future<Either<Failure, bool>> exists(int id) async {
    try {
      return Right(await database.exists(tableName, idColumn, id));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(couldNotVerifyExistenceMessage, e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWhere(Map<String, dynamic> where) async {
    try {
      return Right(await database.delete(table: tableName, where: where));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(couldNotDeleteMessage, e));
    }
  }
}
