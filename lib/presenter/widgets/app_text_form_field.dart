import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String name;

  const AppTextFormField({
    Key? key,
    required this.name,
    this.controller,
    this.keyboardType,
  }) : super(key: key);

  factory AppTextFormField.number({
    Key? key,
    required String name,
    TextEditingController? controller,
  }) =>
      AppTextFormField(
        key: key,
        name: name,
        controller: controller,
        keyboardType: TextInputType.number,
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        label: Text(name),
        border: const OutlineInputBorder(),
      ),
      controller: controller,
    );
  }
}
