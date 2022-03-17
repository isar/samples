// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:quotes/main.dart';
import 'package:quotes/quote.dart';

void main() {
  testWidgets('Isar smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final isar = await Isar.open(
    schemas: [QuoteSchema],
    directory: (await getApplicationDocumentsDirectory()).path,
  );
    await tester.pumpWidget(QuotesApp(isar: isar));

    // Verify that our counter starts at 0.
    expect(find.text('Hey there!'), findsOneWidget);
  });
}
