import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/data/repository/sqlite_order_discount_repository.dart';
import 'package:kitchen_helper/data/repository/sqlite_order_product_repository.dart';
import 'package:kitchen_helper/data/repository/sqlite_recipe_ingredient_repository.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/domain/domain.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/edit_recipe_bloc.dart';
import 'package:kitchen_helper/presenter/widgets/recipe_ingredient_selector_service.dart';
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

class OrderRepositoryMock extends Mock implements OrderRepository {}

class RecipeRepositoryMock extends Mock implements RecipeRepository {}

class RecipeIngredientRepositoryMock extends Mock
    implements RecipeIngredientRepository {}

class OrderProductRepositoryMock extends Mock
    implements OrderProductRepository {}

class OrderDiscountRepositoryMock extends Mock
    implements OrderDiscountRepository {}

class SQLiteDatabaseMock extends Mock implements SQLiteDatabase {}

class RecipeIngredientSelectorServiceMock extends Mock
    implements RecipeIngredientSelectorService {}

class GetRecipeUseCaseMock extends Mock implements GetRecipeUseCase {}

class GetOrderUseCaseMock extends Mock implements GetOrderUseCase {}

class GetOrdersUseCaseMock extends Mock implements GetOrdersUseCase {}

class DeleteOrderUseCaseMock extends Mock implements DeleteOrderUseCase {}

class SaveOrderUseCaseMock extends Mock implements SaveOrderUseCase {}

class GetOrderPriceUseCaseMock extends Mock implements GetOrderPriceUseCase {}

class GetIngredientUseCaseMock extends Mock implements GetIngredientUseCase {}

class GetRecipeCostUseCaseMock extends Mock implements GetRecipeCostUseCase {}

class EditRecipeBlocMock extends Mock implements EditRecipeBloc {}

class FakeIngredient extends Fake implements Ingredient {}

class FakeRecipe extends Fake implements Recipe {}

class FakeOrder extends Fake implements Order {}

class FakeRecipeIngredient extends Fake implements RecipeIngredient {}

class FakeRecipeIngredientEntity extends Fake
    implements RecipeIngredientEntity {}

class FakeOrdersFilter extends Fake implements OrdersFilter {}

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

final cakeRecipe = cakeRecipeWithoutId.copyWith(id: 5);
final cakeRecipeWithoutId = Recipe(
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

final iceCreamRecipe = Recipe(
  id: 4,
  name: 'Ice cream',
  measurementUnit: MeasurementUnit.liters,
  quantityProduced: 2,
  quantitySold: 2,
  canBeSold: true,
  price: 20,
  ingredients: [
    RecipeIngredient.ingredient(sugarWithId.id!, quantity: 200),
  ],
);

const recipeWithRecipeAndIngredients = Recipe(
  id: 2,
  name: 'Complex recipe',
  quantityProduced: 10,
  canBeSold: false,
  measurementUnit: MeasurementUnit.units,
  ingredients: [
    RecipeIngredient.recipe(1, quantity: 5),
    RecipeIngredient.ingredient(3, quantity: 1.5),
  ],
);

const recipeWithIngredients = Recipe(
  id: 1,
  name: 'Recipe With Ingredients',
  quantityProduced: 1,
  canBeSold: false,
  measurementUnit: MeasurementUnit.units,
  ingredients: [
    RecipeIngredient.ingredient(1, quantity: 100),
    RecipeIngredient.ingredient(2, quantity: 200),
  ],
);

const ingredientOne = Ingredient(
  id: 1,
  name: 'Ingredient One',
  measurementUnit: MeasurementUnit.grams,
  quantity: 500,
  cost: 10,
);

const ingredientTwo = Ingredient(
  id: 2,
  name: 'Ingredient Two',
  measurementUnit: MeasurementUnit.milliliters,
  quantity: 2000,
  cost: 50,
);

const ingredientThree = Ingredient(
  id: 3,
  name: 'Ingredient Three',
  measurementUnit: MeasurementUnit.kilograms,
  quantity: 1,
  cost: 25,
);

final ingredientList = [flour, egg, orangeJuice];
final ingredientsMap = {
  flour.id: flour,
  egg.id: egg,
  orangeJuice.id: orangeJuice,
  sugarWithId.id: sugarWithId,
};

final recipesMap = {
  cakeRecipe.id: cakeRecipe,
  iceCreamRecipe.id: iceCreamRecipe,
  sugarWithEggRecipeWithId.id: sugarWithEggRecipeWithId,
  recipeWithIngredients.id: recipeWithIngredients,
  recipeWithRecipeAndIngredients.id: recipeWithRecipeAndIngredients,
};

final cakeOrderProduct = OrderProduct(id: cakeRecipe.id!, quantity: 1);
final iceCreamOrderProduct = OrderProduct(id: iceCreamRecipe.id!, quantity: 2);

final spidermanOrder = Order(
  clientName: 'Test client',
  clientAddress: 'New York Street, 123',
  orderDate: DateTime(2022, 1, 1),
  deliveryDate: DateTime(2022, 1, 2, 15, 30),
  status: OrderStatus.ordered,
  products: [cakeOrderProduct],
  discounts: const [
    Discount(reason: 'Reason', type: DiscountType.percentage, value: 50),
  ],
);
final spidermanOrderWithId = spidermanOrder.copyWith(id: 1);

final batmanOrder = Order(
  id: 2,
  clientName: 'Batman',
  clientAddress: 'Gotham',
  orderDate: DateTime(2022, 1, 3),
  deliveryDate: DateTime(2022, 1, 7, 12),
  status: OrderStatus.delivered,
  products: [cakeOrderProduct, iceCreamOrderProduct],
  discounts: const [
    Discount(reason: 'Reason', type: DiscountType.fixed, value: 10),
  ],
);

IModularNavigator mockNavigator() {
  final navigator = ModularNavigateMock();
  Modular.navigatorDelegate = navigator;
  return navigator;
}
