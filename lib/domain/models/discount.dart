import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discount.g.dart';

@JsonSerializable()
class Discount extends Equatable {
  final String reason;
  final DiscountType type;
  final double value;

  const Discount({
    required this.reason,
    required this.type,
    required this.value,
  });

  factory Discount.fromJson(Map<String, dynamic> json) =>
      _$DiscountFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountToJson(this);

  @override
  List<Object?> get props => [type, value, reason];

  double calculate(double price) {
    if (type == DiscountType.percentage) {
      return price * (value / 100);
    } else {
      return value;
    }
  }
}

enum DiscountType { fixed, percentage }

extension DiscountTypeLabel on DiscountType {
  String get label {
    switch (this) {
      case DiscountType.fixed:
        return 'Valor fixo';
      case DiscountType.percentage:
        return 'Percentual';
    }
  }

  String get name {
    return _$DiscountTypeEnumMap[this]!;
  }
}
