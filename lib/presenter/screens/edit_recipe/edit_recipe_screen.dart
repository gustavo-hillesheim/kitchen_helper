import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/ingredients_list.dart';

import '../../../domain/domain.dart';
import '../../presenter.dart';
import 'widgets/general_information_form.dart';

const cake = Recipe(
    id: 1,
    name: 'Bolo de chocolate',
    measurementUnit: MeasurementUnit.units,
    canBeSold: true,
    quantityProduced: 5,
    quantitySold: 1,
    price: 15,
    ingredients: [
      RecipeIngredient.ingredient(1, quantity: 100),
      RecipeIngredient.ingredient(2, quantity: 2),
      RecipeIngredient.ingredient(3, quantity: 500),
    ],
    notes: '''Modo de preparo:
1. Junte a farinha e o ovo
2. Bata bem
3. Adicione o chocolate
3. Bata mais
4. Bom apetite''');

class EditRecipeScreen extends StatefulWidget {
  final Recipe? initialValue;

  const EditRecipeScreen({
    Key? key,
    this.initialValue = cake,
  }) : super(key: key);

  static Future navigate([Recipe? recipe]) {
    return Modular.to.pushNamed('/edit-recipe', arguments: recipe);
  }

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final _tabsController = TabController(length: 2, vsync: this);
  final _nameController = TextEditingController();
  final _quantityProducedController = TextEditingController();
  final _quantitySoldController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _canBeSoldNotifier = ValueNotifier<bool>(false);
  final _measurementUnitNotifier = ValueNotifier<MeasurementUnit?>(null);
  final _ingredients = const <Ingredient>[
    Ingredient(
      name: 'Chocolate',
      measurementUnit: MeasurementUnit.grams,
      quantity: 100,
      cost: 5,
    ),
    Ingredient(
      name: 'Eggs',
      measurementUnit: MeasurementUnit.units,
      quantity: 2,
      cost: 1,
    ),
    Ingredient(
      name: 'Farinha',
      measurementUnit: MeasurementUnit.grams,
      quantity: 500,
      cost: 15,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      final recipe = widget.initialValue!;
      _nameController.text = recipe.name;
      _quantityProducedController.text =
          Formatter.simple(recipe.quantityProduced);
      _measurementUnitNotifier.value = recipe.measurementUnit;
      _canBeSoldNotifier.value = recipe.canBeSold;
      if (recipe.notes != null) {
        _notesController.text = recipe.notes!;
      }
      if (recipe.canBeSold) {
        final quantitySold = recipe.quantitySold;
        final price = recipe.price;
        if (quantitySold != null) {
          _quantitySoldController.text = Formatter.simple(quantitySold);
        }
        if (price != null) {
          _priceController.text = price.toStringAsFixed(2);
        }
      }
    }
  }

  @override
  void dispose() {
    _tabsController.dispose();
    _nameController.dispose();
    _quantityProducedController.dispose();
    _quantitySoldController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _canBeSoldNotifier.dispose();
    _measurementUnitNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialValue != null ? 'Editar receita' : 'Nova receita',
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: kMediumEdgeInsets.copyWith(bottom: kSmallSpace),
              child: AppTextFormField(
                name: 'Nome',
                controller: _nameController,
              ),
            ),
            TabBar(
              padding: const EdgeInsets.symmetric(horizontal: kMediumSpace),
              controller: _tabsController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.black45,
              tabs: const [
                Tab(text: 'Geral'),
                Tab(text: 'Ingredientes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabsController,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: kMediumEdgeInsets,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GeneralInformationForm(
                            quantityProducedController:
                                _quantityProducedController,
                            notesController: _notesController,
                            quantitySoldController: _quantitySoldController,
                            priceController: _priceController,
                            measurementUnitNotifier: _measurementUnitNotifier,
                            canBeSoldNotifier: _canBeSoldNotifier,
                          ),
                          kMediumSpacerVertical,
                          Text('Custo total: R\$50.00'),
                          ValueListenableBuilder<bool>(
                            valueListenable: _canBeSoldNotifier,
                            builder: (_, canBeSold, __) => canBeSold
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(top: kSmallSpace),
                                    child: Text('Lucro total: R\$25.00'),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IngredientsList(_ingredients),
                ],
              ),
            ),
            Padding(
              padding: kMediumEdgeInsets,
              child: PrimaryButton(
                onPressed: _save,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Saving...'),
    ));
  }
}
