import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboard/data/sport_templates.dart';
import 'package:scoreboard/responsive_counter_page.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:scoreboard/widgets/sport_selection_sheet.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('one-set formats use the singular label', () {
    expect(
      tableTennisTemplate.copyWith(segmentCount: 1).segmentLabel,
      'Best of 1 Set',
    );
  });

  testWidgets('set count changes require confirmation for the selected sport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: ResponsiveCounterPage()));

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    await tester.tapAt(const Offset(200, 400));
    await tester.pump();

    await tester.tap(find.byTooltip('Select Sport'));
    await tester.pumpAndSettle();

    const tableTennisKey = ValueKey('set-count-Table Tennis');
    const badmintonKey = ValueKey('set-count-Badminton');
    const volleyballKey = ValueKey('set-count-Volleyball');
    final setCountDropdown = tester.widget<DropdownButton<int>>(
      find.byKey(tableTennisKey),
    );
    expect(setCountDropdown.items!.map((item) => item.value).toList(), [
      1,
      3,
      5,
      7,
    ]);
    expect(setCountDropdown.value, 5);
    expect(
      tester.widget<DropdownButton<int>>(find.byKey(badmintonKey)).value,
      3,
    );
    expect(
      tester.widget<DropdownButton<int>>(find.byKey(volleyballKey)).value,
      5,
    );
    expect(find.byKey(const ValueKey('set-count-Basketball')), findsNothing);

    await _chooseSetCount(tester, tableTennisKey, 3);
    expect(find.text('Change Number of Sets?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<DropdownButton<int>>(find.byKey(tableTennisKey)).value,
      5,
    );
    expect(find.text('1'), findsOneWidget);

    await _chooseSetCount(tester, tableTennisKey, 3);
    await tester.tap(find.text('Change & Reset'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<DropdownButton<int>>(find.byKey(tableTennisKey)).value,
      3,
    );
    expect(find.text('0'), findsNWidgets(2));
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await _chooseSetCount(tester, badmintonKey, 7);
    expect(find.text('Change Number of Sets?'), findsNothing);
    expect(
      tester.widget<DropdownButton<int>>(find.byKey(badmintonKey)).value,
      7,
    );

    await tester.tap(find.text('Badminton').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Best of 7 Sets  •  First to 21  •  Win by 2'),
      findsOneWidget,
    );
  });

  testWidgets('sport selection scrolls on short screens without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (context) => SportSelectionSheet(
                      sportTemplates: [
                        tableTennisTemplate,
                        badmintonTemplate,
                        volleyballTemplate,
                      ],
                      selectedSport: tableTennisTemplate,
                      onSportSelected: (_) {},
                      onSegmentCountChanged: (_, _) async => false,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Volleyball'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Future<void> _chooseSetCount(
  WidgetTester tester,
  ValueKey<String> sportKey,
  int count,
) async {
  await tester.tap(find.byKey(sportKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text('$count').last);
  await tester.pumpAndSettle();
}
