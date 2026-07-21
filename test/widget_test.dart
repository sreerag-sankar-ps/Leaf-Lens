import 'package:flutter_test/flutter_test.dart';
import 'package:plant_disease_detector/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LeafLensApp());
    expect(find.byType(LeafLensApp), findsOneWidget);
  });
}
