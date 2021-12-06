import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/core/failure.dart';
import 'package:kitchen_helper/core/sqlite/sqlite_database.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:kitchen_helper/domain/repository/ingredient_repository.dart';
import 'package:kitchen_helper/domain/usecases/ingredient/delete_ingredient_usecase.dart';
import 'package:kitchen_helper/domain/usecases/ingredient/get_ingredients_usecase.dart';
import 'package:kitchen_helper/domain/usecases/ingredient/save_ingredient_usecase.dart';
import 'package:mocktail/mocktail.dart';

class ModularNavigateMock extends Mock implements IModularNavigator {}

class GetIngredientsUseCaseMock extends Mock implements GetIngredientsUseCase {}

class SaveIngredientUseCaseMock extends Mock implements SaveIngredientUseCase {}

class DeleteIngredientUseCaseMock extends Mock
    implements DeleteIngredientUseCase {}

class MockIngredientRepository extends Mock implements IngredientRepository {}

class MockSQLiteDatabase extends Mock implements SQLiteDatabase {}

class FakeIngredient extends Fake implements Ingredient {}

class FakeFailure extends Failure {
  FakeFailure(String message) : super(message);
}

final sugarWithId = Ingredient(
  id: 123,
  name: 'Sugar',
  quantity: 100,
  measurementUnit: MeasurementUnit.grams,
  price: 10,
);

final sugarWithoutId = Ingredient(
  name: 'Sugar',
  quantity: 100,
  measurementUnit: MeasurementUnit.grams,
  price: 10,
);

final flour = Ingredient(
  id: 5,
  name: 'Flour',
  quantity: 1,
  measurementUnit: MeasurementUnit.kilograms,
  price: 15.75,
);

final egg = Ingredient(
  id: 6,
  name: 'egg',
  quantity: 12,
  measurementUnit: MeasurementUnit.units,
  price: 10,
);

final orangeJuice = Ingredient(
  id: 7,
  name: 'orange juice',
  quantity: 250,
  measurementUnit: MeasurementUnit.milliliters,
  price: 2.25,
);

final ingredientList = [flour, egg, orangeJuice];

IModularNavigator mockNavigator() {
  final navigator = ModularNavigateMock();
  Modular.navigatorDelegate = navigator;
  return navigator;
}
