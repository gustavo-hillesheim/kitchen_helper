import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'core.dart';

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

  Either<L, NR> combine<NR, OR>(
    Either<L, OR> other,
    NR Function(R, OR) combiner,
  ) {
    if (isLeft()) {
      return asLeftOf();
    }
    if (other.isLeft()) {
      return other.asLeftOf();
    }
    return Right(combiner(
      getRight().toNullable()!,
      other.getRight().toNullable()!,
    ));
  }
}

extension FutureEitherFailureExtension<R> on Future<Either<Failure, R>> {
  Future<R> throwOnFailure() {
    return then((either) {
      return either.fold(
        (failure) => throw failure,
        (r) => r,
      );
    });
  }
}

extension FutureEitherExtension<L, R> on Future<Either<L, R>> {
  Future<Either<NL, NR>> onRightThen<NL, NR>(
      FutureOr<Either<NL, NR>> Function(R) thenFn) {
    return then((result) => result.asyncFlatMap(thenFn));
  }
}

extension IterableExtension<T> on Iterable<T> {
  Future<Iterable<NT>> asyncMap<NT>(Future<NT> Function(T) mapFn) {
    return Future.wait(map(mapFn));
  }
}

extension IterableEitherExtension<L, R> on Iterable<Either<L, R>> {
  Either<L, List<R>> asEitherList() {
    final elements = <R>[];
    for (var i = 0; i < length; i++) {
      final element = elementAt(i);
      if (element.isLeft()) {
        return element.asLeftOf();
      }
      elements.add(element.getRight().toNullable()!);
    }
    return Right(elements);
  }
}
