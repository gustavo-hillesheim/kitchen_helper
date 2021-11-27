import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../domain/models/ingredient.dart';
import '../../constants.dart';
import '../../widgets/bottom_card.dart';
import '../../widgets/sliver_screen_bar.dart';
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
  final controller = ScrollController();
  late final addAction = SliverScreenBarAction(
    icon: Icons.add,
    label: 'Adicionar',
    onPressed: () => _goToEditIngredientScreen(),
  );
  bool isShowingHeader = true;

  @override
  void initState() {
    super.initState();
    bloc = IngredientsListBloc(Modular.get(), Modular.get(), Modular.get());
    bloc.loadIngredients();
    controller.addListener(() {
      setState(() {
        isShowingHeader = controller.offset <
            controller.position.maxScrollExtent - kToolbarHeight * 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: controller,
        floatHeaderSlivers: false,
        headerSliverBuilder: (context, __) => [
          SliverScreenBar(
            title: 'Ingredientes',
            action: addAction,
          ),
        ],
        body: BottomCard(
          child: StreamBuilder<List<Ingredient>?>(
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
                itemCount: ingredients.length,
                itemBuilder: (_, index) => _buildTile(ingredients[index]),
              );
            },
          ),
        ),
      ),
      floatingActionButton: !isShowingHeader
          ? FloatingActionButton(
              onPressed: addAction.onPressed,
              child: Icon(addAction.icon),
              tooltip: addAction.label,
            )
          : null,
    );
  }

  Widget _buildTile(Ingredient ingredient) {
    return Slidable(
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
    );
  }

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
