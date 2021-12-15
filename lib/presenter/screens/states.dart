import 'package:equatable/equatable.dart';
import 'package:kitchen_helper/core/core.dart';

abstract class ScreenState<T> extends Equatable {
  const ScreenState();
}

class LoadingState<T> extends ScreenState<T> {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

class SuccessState<T> extends ScreenState<T> {
  final T value;

  const SuccessState(this.value);

  @override
  List<Object?> get props => [value];
}

class FailureState<T> extends ScreenState<T> {
  final Failure failure;

  const FailureState(this.failure);

  @override
  List<Object?> get props => [failure];
}
