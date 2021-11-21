import 'package:flutter/material.dart';
import 'package:kitchen_helper/domain/models/ingredient.dart';
import 'package:kitchen_helper/domain/models/measurement_unit.dart';
import 'package:kitchen_helper/presenter/screens/ingredients_list/widgets/ingredient_list_tile.dart';

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

class IngredientsListScreen extends StatelessWidget {
  const IngredientsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: false,
        headerSliverBuilder: (context, __) => [
          const SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            collapsedHeight: 75,
            expandedHeight: 200,
            titleSpacing: 0,
            flexibleSpace: Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingredientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Container(
          color: Theme.of(context).colorScheme.primary,
          child: ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (_, index) {
                  final ingredient = ingredients[index];
                  return IngredientListTile(ingredient);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
