import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/widgets/controlled_text_field.dart';

import '../utilities.dart';

void main() {
  testWidgets(
    'test default layout',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const WrapApp(
          widget: ControlledTextField(
            initialValue: 'test',
          ),
        ),
      );
      // Should contain only one text field.
      expect(find.byType(TextField), findsOneWidget);
      // The text field text shoudl be the initialValue.
      expect(find.text('test'), findsOneWidget);
      // There should be no clear button visible.
      expect(find.byType(IconButton), findsNothing);
    },
  );
  testWidgets(
    'test clear button',
    (WidgetTester tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        WrapApp(
          widget: ControlledTextField(
            initialValue: 'test',
            hasClearButton: true,
            focusNode: focusNode,
          ),
        ),
      );

      final findTextField = find.byType(TextField);
      final findIconButton = find.byType(IconButton);

      // The text field should be present.
      expect(findTextField, findsOneWidget);
      // The clear button should not be visible when not in focus.
      expect(findIconButton, findsNothing);

      await tester.tap(findTextField);
      await tester.pumpAndSettle();

      // Tapping and giving the text field focus should make the button appear.
      expect(findIconButton, findsOneWidget);

      await tester.tap(findIconButton);
      await tester.pumpAndSettle();

      // Tapping the clear button should clear the text.
      expect(find.text('test'), findsNothing);
      expect(find.text(''), findsOneWidget);

      focusNode.unfocus();
      await tester.pumpAndSettle();

      // Removing focus should hide the clear button.
      expect(findIconButton, findsNothing);
    },
  );
}
