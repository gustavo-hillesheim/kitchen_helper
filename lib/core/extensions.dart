import 'dart:async';

import 'package:fpdart/fpdart.dart';

extension AsyncMap<L, R> on Either<L, R> {
  Future<Either<NL, NR>> asyncMap<NL, NR>(
      FutureOr<Either<NL, NR>> Function(R) mapFn) async {
    if (isLeft()) {
      return Left((this as Left).value);
    } else {
      return await mapFn((this as Right).value);
    }
  }
}

extension ThenEither<L, R> on Future<Either<L, R>> {
  Future<Either<NL, NR>> thenEither<NL, NR>(
      FutureOr<Either<NL, NR>> Function(R) thenFn) {
    return then((result) => result.asyncMap(thenFn));
  }
}
