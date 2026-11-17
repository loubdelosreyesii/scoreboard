import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoreboard/responsive_counter_page.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('sets use first-to-11 and win-by-2 rules with side winners', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: ResponsiveCounterPage()));

    const leftScorePosition = Offset(200, 400);
    const rightScorePosition = Offset(1000, 400);

    await _tapScore(tester, leftScorePosition, 10);
    await _tapScore(tester, rightScorePosition, 10);
    await _tapScore(tester, leftScorePosition, 1);

    expect(find.text('SET 1 OF 5'), findsOneWidget);
    expect(find.text('11 - 10'), findsNWidgets(2));
    expect(find.text('WIN'), findsNothing);

    await _tapScore(tester, leftScorePosition, 1);

    expect(find.text('SET 2 OF 5'), findsOneWidget);
    expect(find.text('12 - 10'), findsOneWidget);
    expect(find.text('WIN'), findsOneWidget);
    expect(
      tester.getCenter(find.text('WIN')).dx,
      lessThan(tester.getCenter(find.text('12 - 10')).dx),
    );

    await _tapScore(tester, rightScorePosition, 11);

    expect(find.text('SET 3 OF 5'), findsOneWidget);
    expect(find.text('0 - 11'), findsOneWidget);
    expect(find.text('WIN'), findsNWidgets(2));
    expect(
      tester.getCenter(find.text('WIN').last).dx,
      greaterThan(tester.getCenter(find.text('0 - 11')).dx),
    );
  });
}

Future<void> _tapScore(WidgetTester tester, Offset position, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.tapAt(position);
    await tester.pump();
  }
}
