import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/domain.dart';
import '../../presenter.dart';
import '../../widgets/widgets.dart';
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
        RecipesListBloc(Modular.get(), Modular.get(), Modular.get());
    bloc.loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTemplate(
        header: AppBarPageHeader(
          title: 'Receitas',
          context: context,
          action: AppBarPageHeaderAction(
            label: 'Adicionar',
            icon: Icons.add,
            onPressed: _goToEditRecipeScreen,
          ),
        ),
        body: BottomCard(
          child: _buildRecipesList(),
        ),
      ),
    );
  }

  Widget _buildRecipesList() => ScreenStateBuilder<List<Recipe>>(
        stateStream: bloc.stream,
        successBuilder: (_, recipes) {
          if (recipes.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: bloc.loadRecipes,
            child: ListView.builder(
              padding: kSmallEdgeInsets,
              itemCount: recipes.length,
              itemBuilder: (_, index) => _buildTile(recipes[index]),
            ),
          );
        },
        errorBuilder: (_, failure) => _buildErrorState(failure.message),
      );

  Widget _buildEmptyState() => Empty(
        text: 'Sem receitas',
        subtext: 'Adicione receitas e elas aparecerão aqui',
        action: ElevatedButton(
          onPressed: () => _goToEditRecipeScreen(),
          child: const Text('Adicionar receita'),
        ),
      );

  Widget _buildErrorState(String message) => Empty(
        icon: Icons.error_outline_outlined,
        text: 'Erro',
        subtext: message,
        action: ElevatedButton(
          onPressed: bloc.loadRecipes,
          child: const Text('Tente novamente'),
        ),
      );

  Widget _buildTile(Recipe recipe) => Padding(
        padding: const EdgeInsets.only(bottom: kSmallSpace),
        child: ActionsSlider(
          child: RecipeListTile(
            recipe,
            onTap: () => _goToEditRecipeScreen(recipe),
          ),
          onDelete: () => _tryDelete(recipe),
        ),
      );

  void _goToEditRecipeScreen([Recipe? recipe]) async {
    final reload = await EditRecipeScreen.navigate(recipe);
    if (reload ?? false) {
      bloc.loadRecipes();
    }
  }

  void _tryDelete(Recipe recipe) async {
    final result = await bloc.delete(recipe);
    result.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _tryDelete(recipe),
          ),
        ),
      );
    }, (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${recipe.name} foi excluída'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _trySave(recipe),
          ),
        ),
      );
    });
  }

  void _trySave(Recipe recipe) async {
    final result = await bloc.save(recipe);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: () => _trySave(recipe),
            ),
          ),
        );
      },
      (_) {},
    );
  }
}
