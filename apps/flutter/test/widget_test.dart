import 'package:causelog_app/app/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark themes are configured', () {
    final light = AppTheme.light();
    final dark = AppTheme.dark();
    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
  });
}
