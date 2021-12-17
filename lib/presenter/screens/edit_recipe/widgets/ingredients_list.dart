import 'package:flutter/material.dart';
import 'package:kitchen_helper/presenter/screens/edit_recipe/widgets/edit_recipe_ingredient_form.dart';

import '../../../../domain/domain.dart';
import '../../../constants.dart';
import '../../../utils/utils.dart';
import '../../../widgets/secondary_button.dart';
import '../../../widgets/widgets.dart';
import '../models/editing_recipe_ingredient.dart';

class IngredientsList extends StatefulWidget {
  final ValueChanged<RecipeIngredient> onAddIngredient;
  final List<EditingRecipeIngredient> ingredients;

  const IngredientsList(
    this.ingredients, {
    Key? key,
    required this.onAddIngredient,
  }) : super(key: key);

  @override
  State<IngredientsList> createState() => _IngredientsListState();
}

class _IngredientsListState extends State<IngredientsList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.ingredients.length,
          padding: kMediumEdgeInsets.copyWith(bottom: kSmallSpace),
          itemBuilder: (_, i) {
            final ingredient = widget.ingredients[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: kSmallSpace),
              child: ActionsSlider(
                onDelete: () {},
                child: _IngredientListTile(
                  ingredient,
                  onTap: () {},
                ),
              ),
            );
          },
        ),
        SecondaryButton(
          child: Text('Adicionar ingrediente'),
          onPressed: () => showRecipeIngredientForm(context),
        ),
      ],
    );
  }

  void showRecipeIngredientForm(
    BuildContext context, [
    RecipeIngredient? recipeIngredient,
  ]) {
    showDialog(
      context: context,
      builder: (_) {
        return EditRecipeIngredientForm(
          initialValue: recipeIngredient,
          onSave: (recipeIngredient) => setState(() {
            widget.onAddIngredient(recipeIngredient);
            Navigator.of(context).pop();
          }),
        );
      },
    );
  }
}

class _IngredientListTile extends StatelessWidget {
  final EditingRecipeIngredient ingredient;
  final VoidCallback? onTap;

  const _IngredientListTile(
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
      '${Formatter.simple(ingredient.quantity)} '
      '${ingredient.measurementUnit.abbreviation}',
      style: textTheme.headline5!.copyWith(
        fontWeight: FontWeight.w300,
      ),
    );
    final priceText = Text(
      Formatter.price(ingredient.cost),
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
