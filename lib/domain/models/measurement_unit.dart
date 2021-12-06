enum MeasurementUnit { kilograms, grams, liters, milliliters, units }

extension MeasurementUnitExtension on MeasurementUnit {
  String get label {
    switch (this) {
      case MeasurementUnit.kilograms:
        return 'kilogramas';
      case MeasurementUnit.grams:
        return 'gramas';
      case MeasurementUnit.liters:
        return 'litros';
      case MeasurementUnit.milliliters:
        return 'mililitros';
      case MeasurementUnit.units:
        return 'unidades';
    }
  }
}
