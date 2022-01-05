import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/recipe_ingredient_selector_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

class ModularNavigateMock extends Mock implements IModularNavigator {}

class GetIngredientsUseCaseMock extends Mock implements GetIngredientsUseCase {}

class SaveIngredientUseCaseMock extends Mock implements SaveIngredientUseCase {}

class DeleteIngredientUseCaseMock extends Mock
    implements DeleteIngredientUseCase {}

class GetRecipesUseCaseMock extends Mock implements GetRecipesUseCase {}

class SaveRecipeUseCaseMock extends Mock implements SaveRecipeUseCase {}

class DeleteRecipeUseCaseMock extends Mock implements DeleteRecipeUseCase {}

class IngredientRepositoryMock extends Mock implements IngredientRepository {}

class RecipeRepositoryMock extends Mock implements RecipeRepository {}

class RecipeIngredientRepositoryMock extends Mock
    implements RecipeIngredientRepository {}

class SQLiteDatabaseMock extends Mock implements SQLiteDatabase {}

class RecipeIngredientSelectorServiceMock extends Mock
    implements RecipeIngredientSelectorService {}

class GetRecipeUseCaseMock extends Mock implements GetRecipeUseCase {}

class GetIngredientUseCaseMock extends Mock implements GetIngredientUseCase {}

class GetRecipeCostUseCaseMock extends Mock implements GetRecipeCostUseCase {}

class FakeIngredient extends Fake implements Ingredient {}

class FakeRecipe extends Fake implements Recipe {}

class FakeRecipeIngredient extends Fake implements RecipeIngredient {}

class FakeRecipeIngredientEntity extends Fake
    implements RecipeIngredientEntity {}

class FakeFailure extends Failure {
  const FakeFailure(String message) : super(message);
}

class FakeDatabaseException extends DatabaseException with EquatableMixin {
  final String message;

  FakeDatabaseException(this.message) : super(message);

  @override
  int? getResultCode() {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => [message];
}

const sugarWithId = Ingredient(
  id: 123,
  name: 'Sugar',
  quantity: 100,
  measurementUnit: MeasurementUnit.grams,
  cost: 10,
);

const sugarWithoutId = Ingredient(
  name: 'Sugar',
  quantity: 100,
  measurementUnit: MeasurementUnit.grams,
  cost: 10,
);

const flour = Ingredient(
  id: 5,
  name: 'Flour',
  quantity: 1,
  measurementUnit: MeasurementUnit.kilograms,
  cost: 15.75,
);

const egg = Ingredient(
  id: 6,
  name: 'egg',
  quantity: 12,
  measurementUnit: MeasurementUnit.units,
  cost: 10,
);

const orangeJuice = Ingredient(
  id: 7,
  name: 'orange juice',
  quantity: 250,
  measurementUnit: MeasurementUnit.milliliters,
  cost: 2.25,
);

final sugarWithEggRecipeWithoutId = Recipe(
  name: 'Sugar with egg',
  measurementUnit: MeasurementUnit.milliliters,
  quantityProduced: 100,
  canBeSold: false,
  ingredients: [
    RecipeIngredient.ingredient(egg.id!, quantity: 1),
    RecipeIngredient.ingredient(sugarWithId.id!, quantity: 100),
  ],
);

final sugarWithEggRecipeWithId = sugarWithEggRecipeWithoutId.copyWith(id: 1);

final cakeRecipe = Recipe(
  id: 2,
  name: 'Cake',
  measurementUnit: MeasurementUnit.units,
  quantityProduced: 1,
  quantitySold: 1,
  canBeSold: true,
  price: 10,
  ingredients: [
    RecipeIngredient.ingredient(flour.id!, quantity: 1),
    RecipeIngredient.recipe(sugarWithEggRecipeWithId.id!, quantity: 5),
  ],
);

final ingredientList = [flour, egg, orangeJuice];

IModularNavigator mockNavigator() {
  final navigator = ModularNavigateMock();
  Modular.navigatorDelegate = navigator;
  return navigator;
}
