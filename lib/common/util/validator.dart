class Validator {
  static const requiredValueMessage = 'O valor é obrigatório';

  static String? required(Object? value) {
    if (value == null) {
      return requiredValueMessage;
    }
    if (value is String && value.isEmpty) {
      return requiredValueMessage;
    }
    return null;
  }
}
