import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/modules/recipes/presenter/screen/recipes_list/widgets/recipes_filter_display.dart';

import '../../../../../common/common.dart';
import '../../../recipes.dart';
import '../edit_recipe/edit_recipe_screen.dart';
import 'recipes_list_bloc.dart';
import 'widgets/recipe_list_tile.dart';

class RecipesListScreen extends StatefulWidget {
  final RecipesListBloc? bloc;

  const RecipesListScreen({Key? key, this.bloc}) : super(key: key);

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  late final RecipesListBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ??
        RecipesListBloc(
            Modular.get(), Modular.get(), Modular.get(), Modular.get());
    bloc.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListPageTemplate<ListingRecipeDto, Recipe>(
      title: 'Receitas',
      bloc: bloc,
      tileBuilder: (_, recipe) => RecipeListTile(
        recipe,
        onTap: () => _goToEditRecipeScreen(recipe),
      ),
      headerBottom: RecipesFilterDisplay(onFilter: bloc.load),
      deletedMessage: (recipe) => '${recipe.name} foi excluída',
      emptyText: 'Sem receitas',
      emptySubtext: 'Adicione receitas e elas aparecerão aqui',
      emptyActionText: 'Adicionar receita',
      onAdd: _goToEditRecipeScreen,
    );
  }

  void _goToEditRecipeScreen([ListingRecipeDto? recipe]) async {
    final reload = await EditRecipeScreen.navigate(recipe?.id);
    if (reload ?? false) {
      bloc.load();
    }
  }
}
