import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/form_tile.dart';

import '../utilities.dart';

void main() {
  testWidgets(
    'Test text field FormTileContent layout',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidgetScaffold(
          widget: FormTileContent(
            options: TextFieldOptions(title: ''),
          ),
        ),
      );

      final findText = find.byType(Text);
      final findTextField = find.byType(TextField);

      expect(findText, findsOneWidget);
      expect(findTextField, findsOneWidget);
    },
  );

  testWidgets(
    'Test text field FormTileContent enabled',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidgetScaffold(
          widget: FormTileContent(
            enabled: false,
            options: TextFieldOptions(title: ''),
          ),
        ),
      );

      // The text field should be disabled if the enabled argument is set to
      // false;
      final findTextField = find.byType(TextField);
      final textFieldEnabled =
          (findTextField.evaluate().first.widget as TextField).enabled;

      expect(textFieldEnabled, false);
    },
  );

  testWidgets(
    'Test text field options layout',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidgetScaffold(
          widget: FormTileOptions(
            options: TextFieldOptions(title: ''),
          ),
        ),
      );

      final findText = find.byType(Text);
      final findDivider = find.byType(Divider);
      final findTextField = find.byType(ControlledTextField);

      expect(findText, findsNWidgets(4));
      expect(find.text('Text Field Options'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Lines'), findsOneWidget);
      expect(findDivider, findsOneWidget);
      expect(findTextField, findsNWidgets(2));
    },
  );
}
