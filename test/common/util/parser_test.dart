import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/common/common.dart';

void main() {
  group('money', () {
    test('WHEN money uses "," SHOULD parse', () {
      expect(Parser.money('10,00'), 10.00);
      expect(Parser.money('7,50'), 7.5);
      expect(Parser.money('7'), 7);
    });

    test('WHEN money uses "." SHOULD parse', () {
      expect(Parser.money('10.00'), 10.00);
      expect(Parser.money('7.50'), 7.5);
    });
  });
}
