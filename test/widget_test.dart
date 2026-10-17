import 'package:flutter_test/flutter_test.dart';
import 'package:weather/main.dart';

void main() {
  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    expect(find.byType(WeatherApp), findsOneWidget);
  });
}
