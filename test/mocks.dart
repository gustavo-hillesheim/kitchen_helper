import 'package:kitchen_helper/core/failure.dart';
import 'package:kitchen_helper/domain/data/ingredient_repository.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:mocktail/mocktail.dart';

class MockIngredientRepository extends Mock implements IngredientRepository {}

class FakeIngredient extends Fake implements Ingredient {}

class FakeFailure extends Failure {
  FakeFailure(String message) : super(message);
}

final sugarWithId = Ingredient(
  id: '123',
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
