import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:kitchen_helper/common/common.dart';
import 'package:kitchen_helper/common/widget/recipe_ingredient_selector_service.dart';
import 'package:kitchen_helper/core/core.dart';
import 'package:kitchen_helper/database/sqlite/sqlite.dart';
import 'package:kitchen_helper/modules/clients/domain/dto/listing_client_dto.dart';
import 'package:kitchen_helper/modules/clients/domain/model/address.dart';
import 'package:kitchen_helper/modules/clients/domain/model/client.dart';
import 'package:kitchen_helper/modules/clients/domain/model/contact.dart';
import 'package:kitchen_helper/modules/clients/domain/model/states.dart';
import 'package:kitchen_helper/modules/clients/domain/repository/client_repository.dart';
import 'package:kitchen_helper/modules/ingredients/ingredients.dart';
import 'package:kitchen_helper/modules/orders/data/repository/sqlite_order_discount_repository.dart';
import 'package:kitchen_helper/modules/orders/data/repository/sqlite_order_product_repository.dart';
import 'package:kitchen_helper/modules/orders/orders.dart';
import 'package:kitchen_helper/modules/recipes/data/repository/sqlite_recipe_ingredient_repository.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/edit_recipe/edit_recipe_bloc.dart';
import 'package:kitchen_helper/modules/recipes/recipes.dart';
import 'package:mocktail/mocktail.dart';
import 'package:modular_test/modular_test.dart';
import 'package:sqflite/sqflite.dart';

class ModularNavigateMock extends Mock implements IModularNavigator {}

class GetIngredientsUseCaseMock extends Mock implements GetIngredientsUseCase {}

class SaveIngredientUseCaseMock extends Mock implements SaveIngredientUseCase {}

class DeleteIngredientUseCaseMock extends Mock
    implements DeleteIngredientUseCase {}

class GetRecipesUseCaseMock extends Mock implements GetRecipesUseCase {}

class GetRecipesDomainUseCaseMock extends Mock
    implements GetRecipesDomainUseCase {}

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

class ClientRepositoryMock extends Mock implements ClientRepository {}

class SQLiteDatabaseMock extends Mock implements SQLiteDatabase {}

class RecipeIngredientSelectorServiceMock extends Mock
    implements RecipeIngredientSelectorService {}

class GetRecipeUseCaseMock extends Mock implements GetRecipeUseCase {}

class GetOrderUseCaseMock extends Mock implements GetOrderUseCase {}

class GetOrdersUseCaseMock extends Mock implements GetOrdersUseCase {}

class DeleteOrderUseCaseMock extends Mock implements DeleteOrderUseCase {}

class SaveOrderUseCaseMock extends Mock implements SaveOrderUseCase {}

class SaveEditingOrderDtoUseCaseMock extends Mock
    implements SaveEditingOrderDtoUseCase {}

class GetEditingOrderDtoUseCaseMock extends Mock
    implements GetEditingOrderDtoUseCase {}

class GetListingOrderProductsUseCaseMock extends Mock
    implements GetListingOrderProductsUseCase {}

class GetIngredientUseCaseMock extends Mock implements GetIngredientUseCase {}

class GetRecipeCostUseCaseMock extends Mock implements GetRecipeCostUseCase {}

class EditRecipeBlocMock extends Mock implements EditRecipeBloc {}

class FakeIngredient extends Fake implements Ingredient {}

class FakeRecipe extends Fake implements Recipe {}

class FakeOrder extends Fake implements Order {}

class FakeEditingOrderDto extends Fake implements EditingOrderDto {}

class FakeOrderProduct extends Fake implements OrderProduct {}

class FakeRecipeIngredient extends Fake implements RecipeIngredient {}

class FakeRecipeIngredientEntity extends Fake
    implements RecipeIngredientEntity {}

class FakeClient extends Fake implements Client {}

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

  @override
  Object? get result => null;
}

const sugarWithId = Ingredient(
  id: 123,
  name: 'Sugar',
  quantity: 100,
  measurementUnit: MeasurementUnit.grams,
  cost: 10,
);
const listingSugarDto = ListingIngredientDto(
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

const listingFlourDto = ListingIngredientDto(
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
const listingEggDto = ListingIngredientDto(
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
const listingOrangeJuiceDto = ListingIngredientDto(
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

const sugarWithEggRecipeDomain = RecipeDomainDto(
  id: 1,
  label: 'Sugar with egg',
  measurementUnit: MeasurementUnit.milliliters,
);
final sugarWithEggRecipeWithId = sugarWithEggRecipeWithoutId.copyWith(id: 1);
final listingSugarWithEggRecipeDto = ListingRecipeDto(
  id: sugarWithEggRecipeWithId.id!,
  name: sugarWithEggRecipeWithId.name,
  measurementUnit: sugarWithEggRecipeWithId.measurementUnit,
  quantityProduced: sugarWithEggRecipeWithId.quantityProduced,
);

const cakeRecipeDomain = RecipeDomainDto(
  id: 5,
  label: 'Cake',
  measurementUnit: MeasurementUnit.units,
);
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
final listingCakeRecipeDto = ListingRecipeDto(
  id: cakeRecipe.id!,
  name: cakeRecipe.name,
  quantityProduced: cakeRecipe.quantityProduced,
  quantitySold: cakeRecipe.quantitySold,
  price: cakeRecipe.price,
  measurementUnit: cakeRecipe.measurementUnit,
);

const iceCreamRecipeDomain = RecipeDomainDto(
  id: 4,
  label: 'Ice cream',
  measurementUnit: MeasurementUnit.liters,
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
const listingIceCreamRecipeDto = ListingRecipeDto(
  id: 4,
  name: 'Ice cream',
  measurementUnit: MeasurementUnit.liters,
  quantityProduced: 2,
  quantitySold: 2,
  price: 20,
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
final listingIngredientDtoList = [
  listingFlourDto,
  listingEggDto,
  listingOrangeJuiceDto,
];
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
  clientId: spidermanClient.id!,
  addressId: null,
  contactId: null,
  orderDate: DateTime(2022, 1, 1, 1, 10),
  deliveryDate: DateTime(2022, 1, 2, 15, 30),
  status: OrderStatus.ordered,
  products: [cakeOrderProduct],
  discounts: const [
    Discount(reason: 'Reason', type: DiscountType.percentage, value: 50),
  ],
);
final editingSpidermanOrderDto = EditingOrderDto(
  id: spidermanOrderWithId.id!,
  clientId: spidermanClient.id!,
  client: spidermanClient.name,
  addressId: null,
  address: null,
  contactId: null,
  contact: null,
  orderDate: DateTime(2022, 1, 1, 1, 10),
  deliveryDate: DateTime(2022, 1, 2, 15, 30),
  status: OrderStatus.ordered,
  products: [editingOrderProduct(cakeOrderProduct)],
  discounts: const [
    Discount(reason: 'Reason', type: DiscountType.percentage, value: 50),
  ],
);
final spidermanOrderWithId = spidermanOrder.copyWith(id: 1);
final listingSpidermanOrderDto = ListingOrderDto(
  id: 1,
  clientName: 'Test client',
  clientAddress: 'New York Street, 123',
  deliveryDate: DateTime(2022, 1, 2, 15, 30),
  status: OrderStatus.ordered,
  price: 25,
);

final batmanOrder = Order(
  id: 2,
  clientId: batmanClient.id!,
  addressId: 1,
  contactId: 1,
  orderDate: DateTime(2022, 1, 3, 1, 15),
  deliveryDate: DateTime(2022, 1, 7, 12),
  status: OrderStatus.delivered,
  products: [cakeOrderProduct, iceCreamOrderProduct],
  discounts: const [
    Discount(reason: 'Reason', type: DiscountType.fixed, value: 10),
  ],
);
final editingBatmanOrderDto = EditingOrderDto(
  id: 2,
  clientId: batmanClient.id!,
  client: '',
  addressId: 1,
  address: '',
  contactId: 1,
  contact: '',
  orderDate: DateTime(2022, 1, 3, 1, 15),
  deliveryDate: DateTime(2022, 1, 7, 12),
  status: OrderStatus.delivered,
  products: editingOrderProducts([cakeOrderProduct, iceCreamOrderProduct]),
  discounts: const [
    Discount(reason: 'Reason', type: DiscountType.fixed, value: 10),
  ],
);
final listingBatmanOrderDto = ListingOrderDto(
  id: 2,
  clientName: 'Batman',
  clientAddress: 'Gotham',
  deliveryDate: DateTime(2022, 1, 7, 12),
  status: OrderStatus.delivered,
  price: 50,
);
const batmanClient = Client(
  id: 1,
  name: 'Batman',
  addresses: [
    Address(
      identifier: 'Test street, 1',
      cep: 123,
      street: 'Test street',
      number: 1,
      complement: 'Mansion',
      neighborhood: 'Neighborhood',
      city: 'Gotham',
      state: States.SP,
    ),
  ],
  contacts: [
    Contact(contact: '(99) 99999-9999'),
  ],
);
const spidermanClient = Client(
  id: 2,
  name: 'Spider man',
  addresses: [],
  contacts: [],
);

const listingBatmanDto = ListingClientDto(id: 1, name: 'Batman');
const listingSpidermanDto = ListingClientDto(id: 2, name: 'Spider man');

const listingClientDtos = [listingBatmanDto, listingSpidermanDto];

List<EditingOrderProductDto> editingOrderProducts(List<OrderProduct> ops) {
  return ops.map(editingOrderProduct).toList();
}

EditingOrderProductDto editingOrderProduct(OrderProduct op) {
  return EditingOrderProductDto(
    name: recipesMap[op.id]!.name,
    quantity: op.quantity,
    measurementUnit: recipesMap[op.id]!.measurementUnit,
    cost: op.id.toDouble(),
    id: op.id,
    price: op.id.toDouble(),
  );
}

IModularNavigator mockNavigator() {
  final navigator = ModularNavigateMock();
  Modular.navigatorDelegate = navigator;
  return navigator;
}

void mockRecipeIngredientsSelectorService() {
  registerFallbackValue(const NoParams());
  registerFallbackValue(const RecipeFilter());
  final getRecipeUseCase = GetRecipeUseCaseMock();
  final getRecipesUseCase = GetRecipesUseCaseMock();
  final getRecipesDomainUseCase = GetRecipesDomainUseCaseMock();
  final getIngredientsUseCase = GetIngredientsUseCaseMock();
  when(() => getRecipeUseCase.execute(any()))
      .thenAnswer((_) async => const Right(null));
  when(() => getIngredientsUseCase.execute(any()))
      .thenAnswer((_) async => const Right([listingEggDto]));
  when(() => getRecipesUseCase.execute(any())).thenAnswer(
      (_) async => Right([listingCakeRecipeDto, listingIceCreamRecipeDto]));
  when(() => getRecipesDomainUseCase.execute(any())).thenAnswer(
      (_) async => const Right([cakeRecipeDomain, iceCreamRecipeDomain]));
  initModule(FakeModule(
    getRecipeUseCase,
    getRecipesUseCase,
    getIngredientsUseCase,
    getRecipesDomainUseCase,
  ));
}

class FakeModule extends Module {
  final GetRecipeUseCase getRecipeUseCase;
  final GetRecipesUseCase getRecipesUseCase;
  final GetIngredientsUseCase getIngredientsUseCase;
  final GetRecipesDomainUseCase getRecipesDomainUseCase;

  FakeModule(
    this.getRecipeUseCase,
    this.getRecipesUseCase,
    this.getIngredientsUseCase,
    this.getRecipesDomainUseCase,
  );

  @override
  List<Bind<Object>> get binds => [
        Bind.instance<GetRecipeUseCase>(getRecipeUseCase),
        Bind.instance<GetRecipesUseCase>(getRecipesUseCase),
        Bind.instance<GetIngredientsUseCase>(getIngredientsUseCase),
        Bind.instance<GetRecipesDomainUseCase>(getRecipesDomainUseCase),
      ];
}
