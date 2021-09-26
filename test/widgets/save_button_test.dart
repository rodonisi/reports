import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/widgets/save_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'test layout',
    (WidgetTester tester) async {
      // Required for the localization to properly initialize.
      await tester.runAsync(() async {
        await tester.pumpWidget(
          WrapLocalized(
            widget: SaveButton(onPressed: () {}),
          ),
        );
        await tester.pumpAndSettle();
      });
      // Should be an elevated button.
      expect(find.byType(ElevatedButton), findsOneWidget);
      // The button text should be (localized) 'save'
      expect(find.text('Save'), findsOneWidget);
    },
  );
}
