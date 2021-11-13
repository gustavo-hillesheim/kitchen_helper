import 'package:fpdart/fpdart.dart';

import 'failure.dart';

abstract class UseCase<Input, Output> {
  Future<Either<Failure, Output>> execute(Input input);
}
