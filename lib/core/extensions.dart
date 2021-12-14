import 'dart:async';

import 'package:fpdart/fpdart.dart';

extension EitherExtension<L, R> on Either<L, R> {
  Future<Either<NL, NR>> asyncFlatMap<NL, NR>(
      FutureOr<Either<NL, NR>> Function(R) mapFn) async {
    if (isLeft()) {
      return Left((this as Left).value);
    } else {
      return await mapFn((this as Right).value);
    }
  }

  Future<Either<NL, NR>> asyncFold<NL, NR>(
    FutureOr<Either<NL, NR>> Function(L) leftFn,
    FutureOr<Either<NL, NR>> Function(R) rightFn,
  ) async {
    final newEither = fold(leftFn, rightFn);
    return newEither;
  }

  Either<L, NR> asLeftOf<NR>() {
    return Left<L, NR>(getLeft().toNullable()!);
  }
}

extension FutureEitherExtension<L, R> on Future<Either<L, R>> {
  Future<Either<NL, NR>> onRightThen<NL, NR>(
      FutureOr<Either<NL, NR>> Function(R) thenFn) {
    return then((result) => result.asyncFlatMap(thenFn));
  }
}

extension ListExtension<T> on List<T> {
  Future<Iterable<NT>> asyncMap<NT>(Future<NT> Function(T) mapFn) {
    return Future.wait(map(mapFn));
  }
}
