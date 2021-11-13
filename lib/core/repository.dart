import 'package:fpdart/fpdart.dart';

import 'failure.dart';

abstract class Repository<T, ID> {
  Future<Either<Failure, T>> create(T entity);
  Future<Either<Failure, T>> update(T entity);
}
