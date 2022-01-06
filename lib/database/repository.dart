import 'package:fpdart/fpdart.dart';

import '../core/failure.dart';
import 'entity.dart';

abstract class Repository<T extends Entity<ID>, ID> {
  Future<Either<Failure, ID>> save(T entity);

  Future<Either<Failure, ID>> create(T entity);

  Future<Either<Failure, void>> update(T entity);

  Future<Either<Failure, T?>> findById(ID id);

  Future<Either<Failure, void>> deleteById(ID id);

  Future<Either<Failure, List<T>>> findAll();

  Future<Either<Failure, bool>> exists(ID id);

  Future<Either<Failure, void>> deleteWhere(Map<String, dynamic> where);
}
