import 'package:flutter/material.dart';

import '../../presenter.dart';

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({Key? key}) : super(key: key);

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTemplate(
        header: AppBarPageHeader(
          title: 'Receitas',
          context: context,
        ),
        body: BottomCard(
          child: Center(child: Text('Better')),
        ),
      ),
    );
  }
}
