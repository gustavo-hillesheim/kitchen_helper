import 'package:dropdown_search/dropdown_search.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../domain/domain.dart';
import '../../../../extensions.dart';
import '../../../presenter.dart';
import '../models/editing_recipe_ingredient.dart';
import 'recipe_ingredient_selector_service.dart';

class RecipeIngredientSelector extends StatefulWidget {
  static const emptyText = 'Nenhum registro encontrado';
  static const emptySubtext = 'Adicione ingredientes ou receitas e eles '
      'aparecerão aqui';
  static const errorText = 'Erro';
  static const errorSubtext = 'Não foi possível listar os possíveis '
      'ingredientes';

  final EditingRecipeIngredient? initialValue;
  final ValueChanged<SelectorItem?> onChanged;
  final RecipeIngredientSelectorService? service;
  final int? recipeToIgnore;

  const RecipeIngredientSelector({
    Key? key,
    required this.onChanged,
    this.initialValue,
    this.service,
    this.recipeToIgnore,
  }) : super(key: key);

  @override
  State<RecipeIngredientSelector> createState() =>
      _RecipeIngredientSelectorState();
}

class _RecipeIngredientSelectorState extends State<RecipeIngredientSelector> {
  late final RecipeIngredientSelectorService service;
  SelectorItem? initialValue;

  @override
  void initState() {
    super.initState();
    service = widget.service ??
        RecipeIngredientSelectorService(
          Modular.get(),
          Modular.get(),
          Modular.get(),
        );
    if (widget.initialValue != null) {
      initialValue = SelectorItem(
        id: widget.initialValue!.id,
        type: widget.initialValue!.type,
        name: widget.initialValue!.name,
        measurementUnit: widget.initialValue!.measurementUnit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<SelectorItem>(
      selectedItem: initialValue,
      showSearchBox: true,
      onFind: (_) => service
          .getItems(recipeToIgnore: widget.recipeToIgnore)
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

  bool _filterFn(SelectorItem? item, String? search) {
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

  Widget _emptyBuilder(_, __) => const Empty(
        text: RecipeIngredientSelector.emptyText,
        subtext: RecipeIngredientSelector.emptySubtext,
      );

  Widget _errorBuilder(_, __, error) {
    debugPrint(error.toString());
    if (error is Error) {
      debugPrintStack(stackTrace: error.stackTrace);
    }
    return const Empty(
      text: RecipeIngredientSelector.errorText,
      subtext: RecipeIngredientSelector.errorSubtext,
      icon: Icons.error_outline_outlined,
    );
  }
}

class SelectorItem extends Equatable {
  final int id;
  final String name;
  final RecipeIngredientType type;
  final MeasurementUnit measurementUnit;

  const SelectorItem({
    required this.id,
    required this.name,
    required this.type,
    required this.measurementUnit,
  });

  @override
  List<Object?> get props => [id, name, type, measurementUnit];
}
