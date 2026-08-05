import 'package:flutter_test/flutter_test.dart';
import 'package:believe_pos/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Believe POS'), findsOneWidget);
  });
}
