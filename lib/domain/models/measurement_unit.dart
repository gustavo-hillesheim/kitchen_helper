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

  String get abbreviation {
    switch (this) {
      case MeasurementUnit.kilograms:
        return 'Kg';
      case MeasurementUnit.grams:
        return 'g';
      case MeasurementUnit.liters:
        return 'L';
      case MeasurementUnit.milliliters:
        return 'ml';
      case MeasurementUnit.units:
        return 'un';
    }
  }
}
