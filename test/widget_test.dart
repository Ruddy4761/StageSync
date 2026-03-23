import 'package:flutter_test/flutter_test.dart';
import 'package:concert_management_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const StageSyncApp());
    expect(find.text('BackStage'), findsOneWidget);
  });
}
