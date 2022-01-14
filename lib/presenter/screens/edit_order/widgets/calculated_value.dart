import 'package:flutter/material.dart';

import '../../../presenter.dart';

class CalculatedValue extends StatelessWidget {
  final String title;
  final List<CalculationValue> values;

  const CalculatedValue({
    Key? key,
    required this.title,
    required this.values,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatTile(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          kSmallSpacerVertical,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('R\$'),
              Text(
                Formatter.currency(_finalValue, symbol: false),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          kSmallSpacerVertical,
          for (var i = 0; i < values.length; i++) ...[
            _buildCalculationRow(values[i]),
            if (i < values.length - 1) const Divider(),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculationRow(CalculationValue value) {
    const normalTextStyle = TextStyle(fontSize: 12);
    const currencySymbolTextStyle = TextStyle(fontSize: 10);

    return Row(
      children: [
        Text(value.value < 0 ? '-' : '+', style: normalTextStyle),
        kExtraSmallSpacerHorizontal,
        const Text('R\$', style: currencySymbolTextStyle),
        Text(
          Formatter.currency(value.value.abs(), symbol: false),
          style: normalTextStyle,
        ),
        const Spacer(),
        Text(value.description, style: normalTextStyle),
      ],
    );
  }

  double get _finalValue {
    return values.map((v) => v.value).fold(0, (a, b) => a + b);
  }
}

class CalculationValue {
  final double value;
  final String description;

  CalculationValue({
    required this.value,
    required this.description,
  });
}
