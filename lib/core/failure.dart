import 'package:equatable/equatable.dart';
import 'package:sqflite/sqflite.dart';

abstract class Failure extends Equatable {
  final String message;

  Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class BusinessFailure extends Failure {
  BusinessFailure(String message) : super(message);
}

class RepositoryFailure extends Failure {
  RepositoryFailure(String message) : super(message);
}

class DatabaseFailure extends Failure {
  final DatabaseException exception;

  DatabaseFailure(String message, this.exception) : super(message);

  @override
  List<Object?> get props => [message, exception];
}
