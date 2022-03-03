import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sqflite/sqflite.dart';

abstract class Failure extends Equatable {
  final String message;

  Failure(this.message) {
    report();
  }

  void report() {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTest) {
      FirebaseCrashlytics.instance.recordError(this, StackTrace.current);
    }
  }

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

class UnexpectedFailure extends Failure {
  final Object error;

  UnexpectedFailure(this.error) : super('Um erro inesperado aconteceu');

  @override
  List<Object?> get props => [message, error];
}
