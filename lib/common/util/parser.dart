class Parser {
  static double? money(String str) {
    return double.tryParse(str.replaceAll(',', '.'));
  }
}
