import 'package:flutter/material.dart';

import '../utils/validator.dart';

class AppTextFormField extends StatelessWidget {
  final String name;
  final bool required;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? example;

  const AppTextFormField({
    Key? key,
    required this.name,
    this.required = true,
    this.controller,
    this.keyboardType,
    this.prefixText,
    this.example,
  }) : super(key: key);

  const AppTextFormField.number({
    Key? key,
    required this.name,
    this.required = true,
    this.controller,
    this.prefixText,
    this.example = '10',
  })  : keyboardType = TextInputType.number,
        super(key: key);

  const AppTextFormField.money({
    Key? key,
    required this.name,
    this.required = true,
    this.controller,
    this.example = '9.90',
  })  : keyboardType = TextInputType.number,
        prefixText = 'R\$',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: required ? Validator.required : null,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        label: Text(name),
        border: const OutlineInputBorder(),
        prefixText: prefixText,
        hintText: example != null ? 'Ex.: $example' : null,
      ),
      controller: controller,
    );
  }
}
