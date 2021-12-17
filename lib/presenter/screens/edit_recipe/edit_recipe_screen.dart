import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fpdart/fpdart.dart' show Right;

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

  @override
  void initState() {
    super.initState();
    bloc = EditRecipeBloc(Modular.get(), Modular.get(), Modular.get());
    if (widget.initialValue != null) {
      final recipe = widget.initialValue!;
      bloc.getEditingRecipeIngredients(recipe).then((result) {
        result.fold(
          (f) => print(f.message),
          (i) => _ingredients.addAll(i),
        );
      });
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
                                ? const Padding(
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
                  IngredientsList(_ingredients,
                      onAdd: (recipeIngredient) async {
                    bloc
                        .getEditingRecipeIngredient(recipeIngredient)
                        .onRightThen((eri) {
                      setState(() {
                        _ingredients.add(eri);
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
      quantityProduced:
          double.parse(_quantityProducedController.text.replaceAll(',', '.')),
      quantitySold:
          double.tryParse(_quantitySoldController.text.replaceAll(',', '.')),
      price: double.tryParse(_priceController.text.replaceAll(',', '.')),
      ingredients: ingredients,
    );
  }
}
