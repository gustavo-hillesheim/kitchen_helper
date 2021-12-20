import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_helper/presenter/presenter.dart';

void main() {
  test('Should format price correctly', () {
    expect(Formatter.money(1.50), 'R\$1.50');
    expect(Formatter.money(1), 'R\$1.00');
    expect(Formatter.money(0), 'R\$0.00');
    expect(Formatter.money(100.99), 'R\$100.99');
  });

  test('Should format simple correctly', () {
    expect(Formatter.simple(1.50), '1.5');
    expect(Formatter.simple(1), '1');
    expect(Formatter.simple(1.51234), '1.51234');
  });
}
