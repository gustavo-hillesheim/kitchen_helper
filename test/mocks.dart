import 'package:kitchen_helper/core/failure.dart';
import 'package:kitchen_helper/core/sqlite/sqlite_database.dart';
import 'package:kitchen_helper/domain/data/ingredient_repository.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:mocktail/mocktail.dart';

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

final ingredientList = [
  Ingredient(
    name: 'Flour',
    quantity: 1,
    measurementUnit: MeasurementUnit.kilograms,
    price: 15.75,
  ),
  Ingredient(
    name: 'egg',
    quantity: 12,
    measurementUnit: MeasurementUnit.units,
    price: 10,
  ),
  Ingredient(
    name: 'orange juice',
    quantity: 250,
    measurementUnit: MeasurementUnit.milliliters,
    price: 2.25,
  ),
];
