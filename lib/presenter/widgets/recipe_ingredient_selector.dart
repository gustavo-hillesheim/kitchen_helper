import 'package:dropdown_search/dropdown_search.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../domain/domain.dart';
import '../../extensions.dart';
import '../presenter.dart';
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
  RecipeIngredientSelectorItem? initialValue;

  @override
  void initState() {
    super.initState();
    service = widget.service ??
        RecipeIngredientSelectorService(Modular.get(), Modular.get());
    if (widget.initialValue != null) {
      initialValue = RecipeIngredientSelectorItem(
        id: widget.initialValue!.id,
        type: widget.initialValue!.type,
        name: widget.initialValue!.name,
        measurementUnit: widget.initialValue!.measurementUnit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<RecipeIngredientSelectorItem>(
      selectedItem: initialValue,
      showSearchBox: true,
      onFind: (_) => service
          .getItems(
            recipeToIgnore: widget.recipeToIgnore,
            recipeFilter: widget.recipeFilter,
            getOnly: widget.showOnly,
          )
          .throwOnFailure(),
      validator: Validator.required,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      filterFn: _filterFn,
      itemAsString: (item) => item?.name ?? '',
      dropdownBuilderSupportsNullItem: false,
      dropdownBuilder: (_, item) => Text(item?.name ?? ''),
      loadingBuilder: _loadingBuilder,
      emptyBuilder: _emptyBuilder,
      errorBuilder: _errorBuilder,
      onChanged: widget.onChanged,
    );
  }

  bool _filterFn(RecipeIngredientSelectorItem? item, String? search) {
    if (item == null) {
      return false;
    }
    if (search == null) {
      return true;
    }
    return item.name.toLowerCase().startsWith(search.toLowerCase());
  }

  Widget _loadingBuilder(_, __) => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _emptyBuilder(_, __) => Center(
        child: Empty(
          text: RecipeIngredientSelector.emptyText,
          subtext: _showAll
              ? RecipeIngredientSelector.emptySubtext
              : (_showOnlyRecipes
                  ? RecipeIngredientSelector.emptyRecipesSubtext
                  : RecipeIngredientSelector.emptyIngredientsSubtext),
        ),
      );

  Widget _errorBuilder(_, __, error) {
    debugPrint('Error on RecipeIngredientSelector: ${error.toString()}');
    if (error is Error) {
      debugPrintStack(stackTrace: error.stackTrace);
    }
    return const Center(
      child: Empty(
        text: RecipeIngredientSelector.errorText,
        subtext: RecipeIngredientSelector.errorSubtext,
        icon: Icons.error_outline_outlined,
      ),
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
