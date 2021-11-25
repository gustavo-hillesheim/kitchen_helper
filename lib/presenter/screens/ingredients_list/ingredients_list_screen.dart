import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/models/ingredient.dart';
import '../../widgets/bottom_card.dart';
import '../../widgets/sliver_screen_bar.dart';
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
    onPressed: () async {
      final reload = await Modular.to.pushNamed<bool?>('/edit-ingredient');
      if (reload ?? false) {
        bloc.loadIngredients();
      }
    },
  );
  bool isShowingHeader = true;

  @override
  void initState() {
    super.initState();
    bloc = IngredientsListBloc(Modular.get());
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
        body: StreamBuilder<List<Ingredient>?>(
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
            return BottomCard(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: ingredients.length,
                itemBuilder: (_, index) {
                  final ingredient = ingredients[index];
                  return IngredientListTile(ingredient);
                },
              ),
            );
          },
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
}
