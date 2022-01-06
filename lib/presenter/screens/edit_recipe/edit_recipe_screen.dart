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
  final EditRecipeBloc? bloc;
  final Recipe? initialValue;

  const EditRecipeScreen({
    Key? key,
    this.initialValue,
    this.bloc,
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
    bloc = widget.bloc ??
        EditRecipeBloc(
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
    _measurementUnitNotifier.value = recipe.measurementUnit;
    _canBeSoldNotifier.value = recipe.canBeSold;
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
                initialValue: widget.initialValue?.name,
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
                  GeneralInformationForm(
                    initialValue: widget.initialValue,
                    quantityProducedController: _quantityProducedController,
                    notesController: _notesController,
                    quantitySoldController: _quantitySoldController,
                    priceController: _priceController,
                    measurementUnitNotifier: _measurementUnitNotifier,
                    canBeSoldNotifier: _canBeSoldNotifier,
                    cost: _cost,
                    bloc: bloc,
                  ),
                  IngredientsList(
                    _ingredients,
                    onAdd: _onAddIngredient,
                    onEdit: _onEditIngredient,
                    onDelete: _onDeleteIngredient,
                    recipeId: widget.initialValue?.id,
                  ),
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
      quantitySold: Parser.money(_quantitySoldController.text) ?? 0,
      price: Parser.money(_priceController.text) ?? 0,
      ingredients: ingredients,
    );
  }

  void _onAddIngredient(RecipeIngredient recipeIngredient) async {
    bloc.getEditingRecipeIngredient(recipeIngredient).onRightThen((eri) {
      setState(() {
        _ingredients.add(eri);
        _cost += eri.cost;
      });
      return const Right(null);
    });
  }

  void _onEditIngredient(
    EditingRecipeIngredient oldValue,
    RecipeIngredient recipeIngredient,
  ) {
    bloc.getEditingRecipeIngredient(recipeIngredient).onRightThen((newValue) {
      final index = _ingredients.indexOf(oldValue);
      setState(() {
        _ingredients[index] = newValue;
        _cost = _cost - oldValue.cost + newValue.cost;
      });
      return const Right(null);
    });
  }

  void _onDeleteIngredient(EditingRecipeIngredient ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
    });
  }
}
