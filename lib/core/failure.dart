import 'package:equatable/equatable.dart';
import 'package:sqflite/sqflite.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class BusinessFailure extends Failure {
  const BusinessFailure(String message) : super(message);
}

class RepositoryFailure extends Failure {
  const RepositoryFailure(String message) : super(message);
}

class DatabaseFailure extends Failure {
  final DatabaseException exception;

  const DatabaseFailure(String message, this.exception) : super(message);

  @override
  List<Object?> get props => [message, exception];
}

class UnexpectedFailure extends Failure {
  final Object error;

  const UnexpectedFailure(this.error) : super('Um erro inesperado aconteceu');

  @override
  List<Object?> get props => [message, error];
}
