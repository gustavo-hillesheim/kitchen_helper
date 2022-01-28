import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/domain.dart';
import '../../presenter.dart';
import 'ingredients_list_bloc.dart';
import 'widgets/ingredient_list_tile.dart';

class IngredientsListScreen extends StatefulWidget {
  final IngredientsListBloc? bloc;

  const IngredientsListScreen({Key? key, this.bloc}) : super(key: key);

  @override
  State<IngredientsListScreen> createState() => _IngredientsListScreenState();
}

class _IngredientsListScreenState extends State<IngredientsListScreen> {
  late final IngredientsListBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc ??
        IngredientsListBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
          Modular.get(),
        );
    bloc.loadIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWithHeader(
        header: AppBarHeader(
          title: 'Ingredientes',
          context: context,
          action: AppBarHeaderAction(
            label: 'Adicionar',
            icon: Icons.add,
            onPressed: _goToEditIngredientScreen,
          ),
        ),
        body: BottomCard(
          child: _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() => ScreenStateBuilder<List<ListingIngredientDto>>(
        stateStream: bloc.stream,
        successBuilder: (_, ingredients) {
          if (ingredients.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: bloc.loadIngredients,
            child: ListView.builder(
              padding: kSmallEdgeInsets,
              itemCount: ingredients.length,
              itemBuilder: (context, index) => _buildTile(
                context,
                ingredients[index],
              ),
            ),
          );
        },
        errorBuilder: (_, failure) => _buildErrorState(failure.message),
      );

  Widget _buildEmptyState() => Empty(
        text: 'Sem ingredientes',
        subtext: 'Adicione ingredientes e eles aparecerão aqui',
        action: ElevatedButton(
          onPressed: _goToEditIngredientScreen,
          child: const Text('Adicionar ingrediente'),
        ),
      );

  Widget _buildErrorState(String message) => Empty(
        icon: Icons.error_outline_outlined,
        text: 'Erro',
        subtext: message,
        action: ElevatedButton(
          onPressed: bloc.loadIngredients,
          child: const Text('Tente novamente'),
        ),
      );

  Widget _buildTile(
    BuildContext context,
    ListingIngredientDto ingredient,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: kSmallSpace),
        child: ActionsSlider(
          child: IngredientListTile(
            ingredient,
            onTap: () => _goToEditIngredientScreen(ingredient),
          ),
          onDelete: () => _tryDelete(context, ingredient),
        ),
      );

  void _tryDelete(BuildContext context, ListingIngredientDto ingredient) async {
    final result = await bloc.delete(ingredient.id);
    result.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _tryDelete(context, ingredient),
          ),
        ),
      );
    }, (ingredient) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ingredient.name} foi excluído'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _trySave(context, ingredient),
          ),
        ),
      );
    });
  }

  void _trySave(BuildContext context, Ingredient ingredient) async {
    final result = await bloc.save(ingredient);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: () => _trySave(context, ingredient),
            ),
          ),
        );
      },
      (_) {},
    );
  }

  void _goToEditIngredientScreen([ListingIngredientDto? ingredient]) async {
    final reload = await EditIngredientScreen.navigate(ingredient?.id);
    if (reload ?? false) {
      bloc.loadIngredients();
    }
  }
}
