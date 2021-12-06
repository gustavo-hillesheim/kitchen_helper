import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kitchen_helper/core/failure.dart';

import '../../../domain/models/ingredient.dart';
import '../../../domain/usecases/save_ingredient_usecase.dart';

class EditIngredientBloc extends Cubit<EditIngredientState> {
  final SaveIngredientUseCase usecase;

  EditIngredientBloc(this.usecase) : super(EmptyState());

  Future<EditIngredientState> save(Ingredient ingredient) async {
    emit(LoadingState());
    final result = await usecase.execute(ingredient);
    result.fold((failure) => emit(FailureState(failure)),
        (ingredient) => emit(SuccessState(ingredient)));
    return state;
  }
}

abstract class EditIngredientState extends Equatable {}

class EmptyState extends EditIngredientState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends EditIngredientState {
  @override
  List<Object?> get props => [];
}

class FailureState extends EditIngredientState {
  final Failure failure;

  FailureState(this.failure);

  @override
  List<Object?> get props => [failure];
}

class SuccessState extends EditIngredientState {
  final Ingredient ingredient;

  SuccessState(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}
