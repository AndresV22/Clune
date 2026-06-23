import 'package:flutter_test/flutter_test.dart';
import 'package:clune/app/theme/app_theme.dart';

void main() {
  testWidgets('App theme loads correctly', (WidgetTester tester) async {
    expect(AppTheme.light.scaffoldBackgroundColor, isNotNull);
  });
}
