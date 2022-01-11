import 'package:flutter/material.dart';

import '../../../../domain/domain.dart';
import '../../../constants.dart';
import '../../../utils/utils.dart';
import '../../../widgets/secondary_button.dart';
import '../../../widgets/widgets.dart';
import '../models/editing_recipe_ingredient.dart';
import 'edit_recipe_ingredient_form.dart';

typedef OnEditIngredient = void Function(
    EditingRecipeIngredient, RecipeIngredient);
typedef OnAddIngredient = ValueChanged<RecipeIngredient>;
typedef OnDeleteIngredient = ValueChanged<EditingRecipeIngredient>;

class IngredientsList extends StatefulWidget {
  final OnAddIngredient onAdd;
  final OnEditIngredient onEdit;
  final OnDeleteIngredient onDelete;
  final List<EditingRecipeIngredient> ingredients;
  final int? recipeId;

  const IngredientsList(
    this.ingredients, {
    Key? key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.recipeId,
  }) : super(key: key);

  @override
  State<IngredientsList> createState() => _IngredientsListState();
}

class _IngredientsListState extends State<IngredientsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: widget.ingredients.length,
          padding: kMediumEdgeInsets.copyWith(bottom: kSmallSpace),
          itemBuilder: (_, i) {
            final ingredient = widget.ingredients[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: kSmallSpace),
              child: ActionsSlider(
                onDelete: () => widget.onDelete(ingredient),
                child: IngredientListTile(
                  ingredient,
                  onTap: () => showRecipeIngredientForm(context, ingredient),
                ),
              ),
            );
          },
        ),
        Center(
          child: SecondaryButton(
            child: const Text('Adicionar ingrediente'),
            onPressed: () => showRecipeIngredientForm(context),
          ),
        ),
      ],
    );
  }

  void showRecipeIngredientForm(
    BuildContext context, [
    EditingRecipeIngredient? initialValue,
  ]) {
    showDialog(
      context: context,
      builder: (_) {
        return EditRecipeIngredientForm(
          initialValue: initialValue,
          recipeToIgnore: widget.recipeId,
          onSave: (recipeIngredient) => setState(() {
            if (initialValue != null) {
              widget.onEdit(initialValue, recipeIngredient);
            } else {
              widget.onAdd(recipeIngredient);
            }
            Navigator.of(context).pop();
          }),
        );
      },
    );
  }
}

class IngredientListTile extends StatelessWidget {
  final EditingRecipeIngredient ingredient;
  final VoidCallback? onTap;

  const IngredientListTile(
    this.ingredient, {
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameText = Text(
      ingredient.name,
      style: textTheme.headline6!.copyWith(
        fontWeight: FontWeight.w400,
      ),
    );
    final quantityText = Text(
      '${Formatter.simpleNumber(ingredient.quantity)} '
      '${ingredient.measurementUnit.abbreviation}',
      style: textTheme.headline5!.copyWith(
        fontWeight: FontWeight.w300,
      ),
    );
    final priceText = Text(
      Formatter.currency(ingredient.cost),
      style: textTheme.subtitle2,
    );
    final ingredientInfo = Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            nameText,
            kSmallSpacerVertical,
            priceText,
          ],
        ),
        const Spacer(),
        quantityText,
      ],
    );

    return FlatTile(
      child: ingredientInfo,
      onTap: onTap,
    );
  }
}
