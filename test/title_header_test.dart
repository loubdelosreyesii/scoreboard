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
    expect(find.text('CITY CUP 2027'), findsNWidgets(2));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('CITY CUP 2027'), findsOneWidget);
    expect(find.text('Araneta Coliseum'), findsOneWidget);
  });

  testWidgets('header visibility can be toggled off and back on', (
    tester,
  ) async {
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

    await tester.tap(find.byTooltip('Edit match details'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('CITY TABLE TENNIS CUP 2026'), findsNothing);
    await tester.tap(find.byTooltip('Edit tournament header'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('CITY TABLE TENNIS CUP 2026'), findsOneWidget);
  });
}
