import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:mocktail/mocktail.dart';

class ModularNavigateMock extends Mock implements IModularNavigator {}

class GetIngredientsUseCaseMock extends Mock implements GetIngredientsUseCase {}

class SaveIngredientUseCaseMock extends Mock implements SaveIngredientUseCase {}

class DeleteIngredientUseCaseMock extends Mock
    implements DeleteIngredientUseCase {}

class IngredientRepositoryMock extends Mock implements IngredientRepository {}

class SQLiteDatabaseMock extends Mock implements SQLiteDatabase {}

class FakeIngredient extends Fake implements Ingredient {}

class FakeFailure extends Failure {
  FakeFailure(String message) : super(message);
}

const sugarWithId = Ingredient(
  id: 123,
  name: 'Sugar',
  quantity: 100,
  measurementUnit: MeasurementUnit.grams,
  price: 10,
);

const sugarWithoutId = Ingredient(
  name: 'Sugar',
  quantity: 100,
  measurementUnit: MeasurementUnit.grams,
  price: 10,
);

const flour = Ingredient(
  id: 5,
  name: 'Flour',
  quantity: 1,
  measurementUnit: MeasurementUnit.kilograms,
  price: 15.75,
);

const egg = Ingredient(
  id: 6,
  name: 'egg',
  quantity: 12,
  measurementUnit: MeasurementUnit.units,
  price: 10,
);

const orangeJuice = Ingredient(
  id: 7,
  name: 'orange juice',
  quantity: 250,
  measurementUnit: MeasurementUnit.milliliters,
  price: 2.25,
);

final sugarWithEggRecipe = Recipe(
  id: 1,
  name: 'Sugar with egg',
  measurementUnit: MeasurementUnit.milliliters,
  quantityProduced: 100,
  canBeSold: false,
  ingredients: [
    RecipeIngredient.ingredient(egg.id!, quantity: 1),
    RecipeIngredient.ingredient(sugarWithId.id!, quantity: 100),
  ],
);

final ingredientList = [flour, egg, orangeJuice];

IModularNavigator mockNavigator() {
  final navigator = ModularNavigateMock();
  Modular.navigatorDelegate = navigator;
  return navigator;
}
