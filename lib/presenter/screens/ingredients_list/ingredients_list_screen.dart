import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/widgets/ingredient_list_tile.dart';
import 'package:kitchen_helper/presenter/widgets/bottom_card.dart';
import 'package:kitchen_helper/presenter/widgets/sliver_screen_bar.dart';

final ingredients = [
  Ingredient(
    name: 'Açucar',
    quantity: 1,
    measurementUnit: MeasurementUnit.kilograms,
    price: 15,
  ),
  Ingredient(
    name: 'Farinha de trigo',
    quantity: 500,
    measurementUnit: MeasurementUnit.grams,
    price: 32.50,
  ),
  Ingredient(
    name: 'Água',
    quantity: 1,
    measurementUnit: MeasurementUnit.liters,
    price: 1,
  ),
  Ingredient(
    name: 'Suco de limão',
    quantity: 100,
    measurementUnit: MeasurementUnit.milliliters,
    price: 5,
  ),
  Ingredient(
    name: 'Laranja',
    quantity: 10,
    measurementUnit: MeasurementUnit.units,
    price: 10,
  ),
];

class IngredientsListScreen extends StatefulWidget {
  IngredientsListScreen({Key? key}) : super(key: key);

  @override
  State<IngredientsListScreen> createState() => _IngredientsListScreenState();
}

class _IngredientsListScreenState extends State<IngredientsListScreen> {
  final controller = ScrollController();
  final addAction = SliverScreenBarAction(
    icon: Icons.add,
    label: 'Adicionar',
    onPressed: () {
      Modular.to.pushNamed('/edit-ingredient');
    },
  );
  bool isShowingHeader = true;

  @override
  void initState() {
    super.initState();
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ingredients.length,
            itemBuilder: (_, index) {
              final ingredient = ingredients[index];
              return IngredientListTile(ingredient);
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
}
