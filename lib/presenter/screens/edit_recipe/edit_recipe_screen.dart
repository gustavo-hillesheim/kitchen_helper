import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fpdart/fpdart.dart' show Right;
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';

import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../states.dart';
import 'edit_recipe_bloc.dart';
import 'models/editing_recipe_ingredient.dart';
import 'widgets/general_information_form.dart';
import 'widgets/ingredients_list.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe? initialValue;

  const EditRecipeScreen({
    Key? key,
    this.initialValue,
  }) : super(key: key);

  static Future<bool?> navigate([Recipe? recipe]) {
    return Modular.to.pushNamed<bool?>('/edit-recipe', arguments: recipe);
  }

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen>
    with SingleTickerProviderStateMixin {
  late final EditRecipeBloc bloc;
  final _formKey = GlobalKey<FormState>();
  late final _tabsController = TabController(length: 2, vsync: this);
  final _nameController = TextEditingController();
  final _quantityProducedController = TextEditingController();
  final _quantitySoldController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _canBeSoldNotifier = ValueNotifier<bool>(false);
  final _measurementUnitNotifier = ValueNotifier<MeasurementUnit?>(null);
  final _ingredients = <EditingRecipeIngredient>[];
  var _cost = 0.0;

  @override
  void initState() {
    super.initState();
    bloc = EditRecipeBloc(
      Modular.get(),
      Modular.get(),
      Modular.get(),
      Modular.get(),
    );
    if (widget.initialValue != null) {
      final recipe = widget.initialValue!;
      _fillControllers(recipe);
      _fillCost(recipe);
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

  Future<void> _fillControllers(Recipe recipe) async {
    final ingredientsResult = await bloc.getEditingRecipeIngredients(recipe);
    ingredientsResult.fold(
      (f) => print('Ingredients failure: ${f.message}'),
      (i) => _ingredients.addAll(i),
    );
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

  Future<void> _fillCost(Recipe recipe) async {
    final result = await bloc.getCost(recipe);
    result.fold(
      (failure) => print('Cost failure: ${failure.message}'),
      (cost) {
        if (mounted) {
          setState(() {
            _cost = cost;
          });
        }
      },
    );
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
                          Text('Custo total: ${Formatter.money(_cost)}'),
                          _buildProfitIndicators(),
                        ],
                      ),
                    ),
                  ),
                  IngredientsList(_ingredients,
                      onAdd: (recipeIngredient) async {
                    bloc
                        .getEditingRecipeIngredient(recipeIngredient)
                        .onRightThen((eri) {
                      setState(() {
                        _ingredients.add(eri);
                        _cost += eri.cost;
                      });
                      return const Right(null);
                    });
                  }, onEdit: (oldValue, recipeIngredient) {
                    bloc
                        .getEditingRecipeIngredient(recipeIngredient)
                        .onRightThen((newValue) {
                      final index = _ingredients.indexOf(oldValue);
                      setState(() {
                        _ingredients[index] = newValue;
                        _cost = _cost - oldValue.cost + newValue.cost;
                      });
                      return const Right(null);
                    });
                  }, onDelete: (ingredient) {
                    setState(() {
                      _ingredients.remove(ingredient);
                    });
                  }),
                ],
              ),
            ),
            Padding(
              padding: kMediumEdgeInsets,
              child: StreamBuilder<ScreenState>(
                stream: bloc.stream,
                builder: (_, snapshot) => PrimaryButton(
                  onPressed: _save,
                  child: const Text('Salvar'),
                  isLoading: snapshot.data is LoadingState,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      final recipe = _createRecipe();
      final state = await bloc.save(recipe);
      if (state is SuccessState) {
        Modular.to.pop(true);
      } else if (state is FailureState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failure.message)),
        );
      }
    }
  }

  Recipe _createRecipe() {
    final ingredients = _ingredients
        .map((eri) => RecipeIngredient(
              type: eri.type,
              id: eri.id,
              quantity: eri.quantity,
            ))
        .toList();

    return Recipe(
      id: widget.initialValue?.id,
      name: _nameController.text,
      notes: _notesController.text,
      measurementUnit: _measurementUnitNotifier.value!,
      canBeSold: _canBeSoldNotifier.value,
      quantityProduced: Parser.money(_quantityProducedController.text)!,
      quantitySold: Parser.money(_quantitySoldController.text)!,
      price: Parser.money(_priceController.text)!,
      ingredients: ingredients,
    );
  }

  Widget _buildProfitIndicators() {
    return MultiValueListenableBuilder(
      valueListenables: [
        _canBeSoldNotifier,
        _quantityProducedController,
        _quantitySoldController,
        _priceController,
        _measurementUnitNotifier,
      ],
      builder: (_, values, __) {
        if (!values.elementAt(0)) {
          return const SizedBox.shrink();
        }
        final quantityProduced = Parser.money(values.elementAt(1).text);
        final quantitySold = Parser.money(values.elementAt(2).text);
        final pricePerQuantitySold = Parser.money(values.elementAt(3).text);
        final MeasurementUnit? measurementUnit = values.elementAt(4);

        if (quantityProduced == null ||
            quantitySold == null ||
            pricePerQuantitySold == null ||
            measurementUnit == null) {
          return const Text('Informe todos os dados para calcular o lucro');
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            kSmallSpacerVertical,
            Text(_getProfitPerQuantitySoldLabel(
              quantityProduced: quantityProduced,
              quantitySold: quantitySold,
              pricePerQuantitySold: pricePerQuantitySold,
              measurementUnit: measurementUnit,
            )),
            kSmallSpacerVertical,
            Text(_getTotalProfitLabel(
              quantityProduced: quantityProduced,
              quantitySold: quantitySold,
              pricePerQuantitySold: pricePerQuantitySold,
            )),
          ],
        );
      },
    );
  }

  String _getProfitPerQuantitySoldLabel({
    required double quantityProduced,
    required double quantitySold,
    required double pricePerQuantitySold,
    required MeasurementUnit measurementUnit,
  }) {
    final profitPerQuantitySold = bloc.calculateProfitPerQuantitySold(
      quantityProduced: quantityProduced,
      quantitySold: quantitySold,
      pricePerQuantitySold: pricePerQuantitySold,
      totalCost: _cost,
    );
    return 'Lucro por '
        '${Formatter.simple(quantitySold)} '
        '${measurementUnit.label}: '
        '${Formatter.money(profitPerQuantitySold)}';
  }

  String _getTotalProfitLabel({
    required double quantityProduced,
    required double quantitySold,
    required double pricePerQuantitySold,
  }) {
    final profit = bloc.calculateTotalProfit(
      quantityProduced: quantityProduced,
      quantitySold: quantitySold,
      pricePerQuantitySold: pricePerQuantitySold,
      totalCost: _cost,
    );
    return 'Lucro total: ${Formatter.money(profit)}';
  }
}
