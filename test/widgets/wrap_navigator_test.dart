import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/widgets/wrap_navigator.dart';

import '../utilities.dart';

void main() {
  late Widget target;
  final key = ValueKey('container');
  final key2 = ValueKey('container2');
  setUpAll(() {});

  testWidgets('one child', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WrapNavigator(
          child: MaterialPage(
            child: Container(
              key: key,
            ),
          ),
        ),
      ),
    );
    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('multiple pages', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WrapNavigator(
          child: MaterialPage(
            child: Container(
              key: key,
            ),
          ),
          additionalPages: [
            MaterialPage(
              child: Scaffold(
                appBar: AppBar(),
                body: Container(
                  key: key2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // The second container should be visible.
    expect(find.byKey(key2), findsOneWidget);
    expect(find.byKey(key), findsNothing);

    // Pop the page.
    await tester.pageBack();
    await tester.pump();

    // The first container should be visible.
    expect(find.byKey(key), findsOneWidget);
  });

  testWidgets('custom onPopPage', (WidgetTester tester) async {
    var counter = 0;
    var onPopPage = (Route<dynamic> route, result) {
      counter++;
      return route.didPop(result);
    };

    await tester.pumpWidget(
      MaterialApp(
        home: WrapNavigator(
          child: MaterialPage(
            child: Container(
              key: key,
            ),
          ),
          additionalPages: [
            MaterialPage(
              child: Scaffold(
                appBar: AppBar(),
                body: Container(
                  key: key2,
                ),
              ),
            ),
          ],
          onPopPage: onPopPage,
        ),
      ),
    );

    // Pop the page.
    await tester.pageBack();
    await tester.pump();

    expect(counter, 1);
  });
}
