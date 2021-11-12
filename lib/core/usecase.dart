import 'package:fpdart/fpdart.dart';
import 'package:kitchen_helper/core/failure.dart';

abstract class UseCase<Input, Output> {
  Future<Either<Failure, Output>> execute(Input input);
}
