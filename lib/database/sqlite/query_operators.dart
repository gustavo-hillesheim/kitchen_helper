import 'package:equatable/equatable.dart';

abstract class QueryOperator<T> extends Equatable {
  final T value;

  const QueryOperator(this.value);

  String get operation;
}

class Contains extends QueryOperator<String> {
  const Contains(String value) : super(value);

  @override
  String get operation => "LIKE '%' || ? || '%'";

  @override
  List<Object?> get props => [value];
}
