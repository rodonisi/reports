import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/widgets/save_button.dart';

import '../utilities.dart';

void main() {
  testWidgets(
    'test layout',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidgetScaffold(
          widget: SaveButton(onPressed: () {}),
        ),
      );

      // Should be an elevated button.
      expect(find.byType(ElevatedButton), findsOneWidget);
      // The button text should be (localized) 'save'
      expect(find.text('Save'), findsOneWidget);
    },
  );
}
