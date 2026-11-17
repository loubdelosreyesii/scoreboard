import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboard/widgets/title_header.dart';

void main() {
  testWidgets('title header displays and edits event details', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TitleHeader(),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    expect(find.text('CITY TABLE TENNIS CUP 2026'), findsOneWidget);
    expect(find.text('Pasig Sports Center'), findsOneWidget);
    expect(find.text('24 Oct 2026'), findsOneWidget);
    expect(find.text('9:00 AM'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit match details'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'CITY CUP 2027');
    await tester.enterText(find.byType(TextField).last, 'Araneta Coliseum');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('CITY CUP 2027'), findsOneWidget);
    expect(find.text('Araneta Coliseum'), findsOneWidget);
  });
}
