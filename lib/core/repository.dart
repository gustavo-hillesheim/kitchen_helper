import 'package:fpdart/fpdart.dart';

import 'failure.dart';

abstract class Repository<T extends Entity<ID>, ID> {
  Future<Either<Failure, ID>> create(T entity);
  Future<Either<Failure, void>> update(T entity);
  Future<Either<Failure, T?>> findById(ID id);
  Future<Either<Failure, void>> deleteById(ID id);
  Future<Either<Failure, List<T>>> findAll();
}

abstract class Entity<ID> {
  ID? get id;
}
