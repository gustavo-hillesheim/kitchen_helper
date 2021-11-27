class Validator {
  static String? required(Object? value) {
    if (value == null) {
      return 'O valor é obrigatório';
    }
    if (value is String && value.isEmpty) {
      return 'O valor é obrigatório';
    }
    return null;
  }
}
