import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../widgets/app_bar_page_header.dart';
import '../../widgets/page_template.dart';

import '../../../domain/models/ingredient.dart';
import '../../constants.dart';
import '../../widgets/bottom_card.dart';
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

  Widget _buildIngredientsList() => StreamBuilder<List<Ingredient>?>(
        stream: bloc.stream,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final ingredients = snapshot.data;
          if (ingredients!.isEmpty) {
            return const Center(child: Text('Sem ingredientes'));
          }
          return ListView.builder(
            padding: kSmallEdgeInsets,
            itemCount: ingredients.length * 15,
            itemBuilder: (_, index) => _buildTile(ingredients[index ~/ 15]),
          );
        },
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
                onPressed: (context) => _deleteIngredient(ingredient, context),
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

  void _deleteIngredient(Ingredient ingredient, BuildContext context) async {
    bloc.delete(ingredient);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ingredient.name} foi excluído'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () => bloc.save(ingredient),
        ),
      ),
    );
  }
}
