import 'package:flutter/material.dart';

import '../common.dart';

class AppTextFormField extends StatefulWidget {
  final String name;
  final bool required;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? example;
  final bool? multiline;
  final String? initialValue;

  const AppTextFormField({
    Key? key,
    required this.name,
    this.required = true,
    this.controller,
    this.keyboardType,
    this.prefixText,
    this.example,
    this.multiline,
    this.initialValue,
  }) : super(key: key);

  AppTextFormField.number({
    Key? key,
    required this.name,
    this.required = true,
    this.controller,
    this.prefixText,
    this.example = '10',
    this.multiline,
    num? initialValue,
  })  : keyboardType = TextInputType.number,
        initialValue =
            initialValue != null ? Formatter.simpleNumber(initialValue) : null,
        super(key: key);

  AppTextFormField.money({
    Key? key,
    required this.name,
    this.required = true,
    this.controller,
    this.example = '9.90',
    this.multiline,
    num? initialValue,
  })  : keyboardType = TextInputType.number,
        prefixText = 'R\$',
        initialValue = initialValue?.toStringAsFixed(2),
        super(key: key);

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue;
    controller = widget.controller ?? TextEditingController();
    if (controller.text.isEmpty && initialValue != null) {
      controller.text = initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.required ? Validator.required : null,
      keyboardType: widget.keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: widget.multiline ?? false ? null : 1,
      decoration: InputDecoration(
        label: Text(widget.name),
        prefixText: widget.prefixText,
        hintText: widget.example != null ? 'Ex.: ${widget.example}' : null,
      ),
      controller: controller,
    );
  }
}
