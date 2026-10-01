import 'package:flutter_test/flutter_test.dart';
import 'package:appliquation_mobile/main.dart';

void main() {
  testWidgets('Bloom Rose App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BloomRoseApp());
    expect(find.byType(BloomRoseApp), findsOneWidget);
  });
}
