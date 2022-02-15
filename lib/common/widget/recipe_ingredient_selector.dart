import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../extensions.dart';
import '../../modules/recipes/recipes.dart';
import '../common.dart';
import 'recipe_ingredient_selector_service.dart';

enum RecipeIngredientSelectorItems { all, ingredients, recipes }

class RecipeIngredientSelector extends StatefulWidget {
  static const emptyText = 'Nenhum registro encontrado';
  static const emptySubtext = 'Adicione ingredientes ou receitas e eles '
      'aparecerão aqui';
  static const emptyRecipesSubtext = 'Adicione receitas e elas aparecerão aqui';
  static const emptyIngredientsSubtext =
      'Adicione ingredientes e eles aparecerão aqui';
  static const errorText = 'Erro';
  static const errorSubtext = 'Não foi possível listar os possíveis '
      'ingredientes';

  final RecipeIngredientSelectorItem? initialValue;
  final ValueChanged<RecipeIngredientSelectorItem?> onChanged;
  final RecipeIngredientSelectorService? service;
  final RecipeFilter? recipeFilter;
  final int? recipeToIgnore;
  final RecipeIngredientSelectorItems showOnly;

  const RecipeIngredientSelector({
    Key? key,
    required this.onChanged,
    this.initialValue,
    this.recipeFilter,
    this.service,
    this.recipeToIgnore,
    this.showOnly = RecipeIngredientSelectorItems.all,
  }) : super(key: key);

  @override
  State<RecipeIngredientSelector> createState() =>
      _RecipeIngredientSelectorState();
}

class _RecipeIngredientSelectorState extends State<RecipeIngredientSelector> {
  late final RecipeIngredientSelectorService service;
  RecipeIngredientSelectorItem? value;

  @override
  void initState() {
    super.initState();
    service = widget.service ??
        RecipeIngredientSelectorService(Modular.get(), Modular.get());
    if (widget.initialValue != null) {
      value = RecipeIngredientSelectorItem(
        id: widget.initialValue!.id,
        type: widget.initialValue!.type,
        name: widget.initialValue!.name,
        measurementUnit: widget.initialValue!.measurementUnit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchTextField<RecipeIngredientSelectorItem>(
      name: 'Ingrediente',
      value: value,
      onChanged: (newValue) => setState(() {
        value = newValue;
        widget.onChanged(newValue);
      }),
      onSearch: (_) => service
          .getItems(
            recipeToIgnore: widget.recipeToIgnore,
            recipeFilter: widget.recipeFilter,
            getOnly: widget.showOnly,
          )
          .throwOnFailure(),
      getContentLabel: (item) => item?.name ?? '',
      emptyTitle: RecipeIngredientSelector.emptyText,
      emptySubtext: _showAll
          ? RecipeIngredientSelector.emptySubtext
          : (_showOnlyRecipes
              ? RecipeIngredientSelector.emptyRecipesSubtext
              : RecipeIngredientSelector.emptyIngredientsSubtext),
      errorTitle: RecipeIngredientSelector.errorText,
      errorSubtext: RecipeIngredientSelector.errorSubtext,
    );
  }

  bool get _showAll => widget.showOnly == RecipeIngredientSelectorItems.all;

  bool get _showOnlyRecipes =>
      widget.showOnly == RecipeIngredientSelectorItems.recipes;
}

class RecipeIngredientSelectorItem extends Equatable {
  final int id;
  final String name;
  final RecipeIngredientType type;
  final MeasurementUnit measurementUnit;

  const RecipeIngredientSelectorItem({
    required this.id,
    required this.name,
    required this.type,
    required this.measurementUnit,
  });

  @override
  List<Object?> get props => [id, name, type, measurementUnit];
}
