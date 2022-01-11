import 'package:fpdart/fpdart.dart';

import '../../../../domain/domain.dart';
import '../../states.dart';

class OrderListTileBloc extends AppCubit<List<OrderProductData>> {
  OrderListTileBloc() : super(const EmptyState());

  Future<void> loadProducts() async {
    runEither(() async {
      await Future.delayed(Duration(seconds: 1));
      return Right([
        OrderProductData(
          quantity: 1,
          measurementUnit: MeasurementUnit.units,
          name: 'Bolo de chocolate',
        ),
        OrderProductData(
          quantity: 100,
          measurementUnit: MeasurementUnit.units,
          name: 'Brigadeiros',
        ),
        OrderProductData(
          quantity: 50,
          measurementUnit: MeasurementUnit.units,
          name: 'Torradas',
        ),
        OrderProductData(
          quantity: 500,
          measurementUnit: MeasurementUnit.grams,
          name: 'Patê de frango',
        ),
        OrderProductData(
          quantity: 500,
          measurementUnit: MeasurementUnit.grams,
          name: 'Maionese',
        ),
        OrderProductData(
          quantity: 2,
          measurementUnit: MeasurementUnit.units,
          name: 'Empadão de brócolis',
        ),
      ]);
    });
  }
}

class OrderProductData {
  final double quantity;
  final MeasurementUnit measurementUnit;
  final String name;

  OrderProductData({
    required this.quantity,
    required this.measurementUnit,
    required this.name,
  });
}
