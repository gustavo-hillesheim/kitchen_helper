import 'package:equatable/equatable.dart';

import '../../../../common/common.dart';
import '../../../recipes/recipes.dart';
import '../domain.dart';

class EditingOrderProductDto extends Equatable {
  final String name;
  final double quantity;
  final MeasurementUnit measurementUnit;
  final double cost;
  final double price;
  final int id;

  const EditingOrderProductDto({
    required this.name,
    required this.quantity,
    required this.measurementUnit,
    required this.cost,
    required this.id,
    required this.price,
  });

  factory EditingOrderProductDto.fromModels(
    OrderProduct orderProduct,
    Recipe recipe,
    double recipeCost,
  ) {
    return EditingOrderProductDto(
      name: recipe.name,
      quantity: orderProduct.quantity,
      measurementUnit: recipe.measurementUnit,
      cost: recipeCost * (orderProduct.quantity / recipe.quantityProduced),
      id: orderProduct.id,
      price: recipe.price! * (orderProduct.quantity / recipe.quantitySold!),
    );
  }

  EditingOrderProductDto copyWith({
    String? name,
    double? quantity,
    MeasurementUnit? measurementUnit,
    double? cost,
    double? quantitySold,
    double? price,
    int? id,
  }) {
    return EditingOrderProductDto(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [id, name, quantity, measurementUnit, cost, price];
}
