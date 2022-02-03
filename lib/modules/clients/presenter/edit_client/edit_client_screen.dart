import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'edit_client_bloc.dart';

class EditClientScreen extends StatefulWidget {
  final int? id;

  const EditClientScreen({Key? key, this.id}) : super(key: key);

  static Future<bool?> navigate([int? id]) {
    return Modular.to.pushNamed<bool?>('./edit', arguments: id);
  }

  @override
  _EditClientScreenState createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late EditClientBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = EditClientBloc(Modular.get(), Modular.get());
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Edit Client Screen'));
  }
}
