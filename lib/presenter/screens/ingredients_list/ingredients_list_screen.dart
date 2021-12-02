import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../domain/models/ingredient.dart';
import '../../constants.dart';
import '../../widgets/app_bar_page_header.dart';
import '../../widgets/bottom_card.dart';
import '../../widgets/empty.dart';
import '../../widgets/page_template.dart';
import '../edit_ingredient/edit_ingredient_screen.dart';
import 'ingredients_list_bloc.dart';
import 'widgets/ingredient_list_tile.dart';

class IngredientsListScreen extends StatefulWidget {
  const IngredientsListScreen({Key? key}) : super(key: key);

  @override
  State<IngredientsListScreen> createState() => _IngredientsListScreenState();
}

class _IngredientsListScreenState extends State<IngredientsListScreen> {
  late final IngredientsListBloc bloc;
  bool isShowingHeader = true;

  @override
  void initState() {
    super.initState();
    bloc = IngredientsListBloc(Modular.get(), Modular.get(), Modular.get());
    bloc.loadIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTemplate(
        header: AppBarPageHeader(
          title: 'Ingredientes',
          action: AppBarPageHeaderAction(
            icon: Icons.add,
            label: 'Adicionar',
            onPressed: () => _goToEditIngredientScreen(),
          ),
          context: context,
        ),
        body: BottomCard(
          child: _buildIngredientsList(),
        ),
      ),
    );
  }

  Widget _buildIngredientsList() => StreamBuilder<IngredientListState>(
        stream: bloc.stream,
        builder: (_, snapshot) {
          if (!snapshot.hasData || snapshot.data is LoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final state = snapshot.data;
          if (state is FailureState) {
            return _buildErrorState();
          }
          final ingredients = (state as SuccessState).ingredients;
          if (ingredients.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: kSmallEdgeInsets,
            itemCount: ingredients.length,
            itemBuilder: (_, index) => _buildTile(ingredients[index]),
          );
        },
      );

  Widget _buildErrorState() => Empty(
        icon: Icons.error_outline_outlined,
        text: 'Erro',
        subtext: 'Não foi possível carregar os ingredientes',
        action: ElevatedButton(
          onPressed: bloc.loadIngredients,
          child: const Text('Tente novamente'),
        ),
      );

  Widget _buildEmptyState() => Empty(
        text: 'Sem ingredientes',
        subtext: 'Adicione ingredientes e eles aparecerão aqui',
        action: ElevatedButton(
          onPressed: () => _goToEditIngredientScreen(),
          child: const Text('Adicionar ingrediente'),
        ),
      );

  Widget _buildTile(Ingredient ingredient) => Padding(
        padding: const EdgeInsets.only(bottom: kSmallSpace),
        child: Slidable(
          closeOnScroll: true,
          endActionPane: ActionPane(
            extentRatio: 0.25,
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => _tryDelete(ingredient),
                icon: Icons.delete,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                label: 'Excluir',
              ),
            ],
          ),
          child: IngredientListTile(
            ingredient,
            onTap: () => _goToEditIngredientScreen(ingredient),
          ),
        ),
      );

  void _goToEditIngredientScreen([Ingredient? ingredient]) async {
    final reload = await EditIngredientScreen.navigate(ingredient);
    if (reload ?? false) {
      bloc.loadIngredients();
    }
  }

  void _tryDelete(Ingredient ingredient) async {
    final result = await bloc.delete(ingredient);
    result.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          action: SnackBarAction(
            label: 'Tentar novamente',
            onPressed: () => _tryDelete(ingredient),
          ),
        ),
      );
    }, (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ingredient.name} foi excluído'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => _trySave(ingredient),
          ),
        ),
      );
    });
  }

  void _trySave(Ingredient ingredient) async {
    final result = await bloc.save(ingredient);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            action: SnackBarAction(
              label: 'Tentar novamente',
              onPressed: () => _trySave(ingredient),
            ),
          ),
        );
      },
      (_) {},
    );
  }
}
