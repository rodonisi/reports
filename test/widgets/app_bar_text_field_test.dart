import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/common/theme.dart';
import 'package:reports/widgets/app_bar_text_field.dart';

import '../utilities.dart';

Widget get _getBasicWidget {
  return wrapWidgetScaffold(
    widget: AppBarTextField(
      controller: TextEditingController(),
    ),
  );
}

Widget get _getLightWidget {
  return wrapWidgetScaffold(
    widget: AppBarTextField(
      controller: TextEditingController(),
    ),
    theme: lightTheme,
  );
}

Widget get _getDarkWidget {
  return wrapWidgetScaffold(
    widget: AppBarTextField(
      controller: TextEditingController(),
    ),
    theme: darkTheme,
  );
}

void main() {
  testWidgets(
    'Test enter text',
    (WidgetTester tester) async {
      await tester.pumpWidget(_getBasicWidget);
      final findTextField = find.byType(TextField);
      await tester.enterText(findTextField, 'test');

      expect(find.text('test'), findsOneWidget);
    },
  );

  testWidgets(
    'Test clear button',
    (WidgetTester tester) async {
      await tester.pumpWidget(_getBasicWidget);

      final findTextField = find.byType(TextField);
      final findButton = find.byType(IconButton);

      // No button should be shown when the field is not in focus.
      expect(findButton, findsNothing);

      // The button should be shown when in foucs.
      await tester.enterText(findTextField, 'text');
      await tester.pump();
      expect(findButton, findsOneWidget);

      // Tapping the clear button should clear the text.
      await tester.tap(findButton);
      expect(find.text('text'), findsNothing);

      // Unfocusing the text field should hide the clear button.
      final focusState = tester.state(findTextField);
      FocusScope.of(focusState.context).requestFocus(FocusNode());
      await tester.pump();
      expect(findButton, findsNothing);
    },
  );

  testWidgets(
    'Test light mode colors',
    (WidgetTester tester) async {
      await tester.pumpWidget(_getLightWidget);

      final findTextField = find.byType(TextField);
      final findIcon = find.byType(Icon);

      await tester.enterText(findTextField, 'text');
      await tester.pump();

      final textFieldColor =
          (findTextField.evaluate().first.widget as TextField).style!.color;
      final buttonColor = (findIcon.evaluate().first.widget as Icon).color;
      expect(textFieldColor, lightTheme.textTheme.bodyText1!.color);
      expect(buttonColor, lightTheme.textTheme.bodyText1!.color);
    },
  );

  testWidgets(
    'Test dark mode colors',
    (WidgetTester tester) async {
      await tester.pumpWidget(_getDarkWidget);

      final findTextField = find.byType(TextField);
      final findIcon = find.byType(Icon);

      await tester.enterText(findTextField, 'text');
      await tester.pump();

      final textFieldColor =
          (findTextField.evaluate().first.widget as TextField).style!.color;
      final buttonColor = (findIcon.evaluate().first.widget as Icon).color;
      expect(textFieldColor, darkTheme.textTheme.bodyText1!.color);
      expect(buttonColor, darkTheme.textTheme.bodyText1!.color);
    },
  );
}
