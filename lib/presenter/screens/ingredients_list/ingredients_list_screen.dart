import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../domain/domain.dart';
import '../../widgets/widgets.dart';
import '../edit_ingredient/edit_ingredient_screen.dart';
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
        IngredientsListBloc(Modular.get(), Modular.get(), Modular.get());
    bloc.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListPageTemplate<Ingredient>(
      title: 'Ingredientes',
      bloc: bloc,
      tileBuilder: (_, ingredient) => IngredientListTile(
        ingredient,
        onTap: () => _goToEditIngredientScreen(ingredient),
      ),
      deletedMessage: (ingredient) => '${ingredient.name} foi excluído',
      emptyText: 'Sem ingredientes',
      emptySubtext: 'Adicione ingredientes e eles aparecerão aqui',
      emptyActionText: 'Adicionar ingrediente',
      onAdd: () => _goToEditIngredientScreen(),
    );
  }

  void _goToEditIngredientScreen([Ingredient? ingredient]) async {
    final reload = await EditIngredientScreen.navigate(ingredient?.id);
    if (reload ?? false) {
      bloc.load();
    }
  }
}
