import 'package:bloc/bloc.dart';

import '../../../domain/models/ingredient.dart';
import '../../../domain/usecases/save_ingredient_usecase.dart';

class EditIngredientBloc extends Cubit<void> {
  final SaveIngredientUseCase usecase;

  EditIngredientBloc(this.usecase) : super(null);

  save(Ingredient ingredient) async {
    await usecase.execute(ingredient);
  }
}
