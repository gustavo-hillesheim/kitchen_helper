import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/core.dart';

abstract class ScreenState<T> extends Equatable {
  const ScreenState();

  @override
  List<Object?> get props => [];
}

class EmptyState<T> extends ScreenState<T> {
  const EmptyState();
}

class LoadingState<T> extends ScreenState<T> {
  const LoadingState();
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

abstract class AppCubit<T> extends Cubit<ScreenState<T>> {
  AppCubit(ScreenState<T> initialState) : super(initialState);

  Future<Either<Failure, T>> runEither(
      Future<Either<Failure, T>> Function() fn) async {
    try {
      emit(LoadingState<T>());
      final result = await fn();
      result.fold(
        (failure) => emit(FailureState<T>(failure)),
        (value) => emit(SuccessState<T>(value)),
      );
      return result;
    } catch (e) {
      final failure = UnexpectedFailure(e);
      emit(FailureState<T>(failure));
      return Left(failure);
    }
  }
}
