import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/widgets/app_bar_text_field.dart';

import '../utilities.dart';

void main() {
  testWidgets(
    'Test base layout',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWidgetMaterial(
          widget: FormBuilder(
            args: FormBuilderArgs(name: 'test'),
          ),
        ),
      );

      await tester.runAsync(() async {
        final findAppBar = find.byType(AppBar);
        final findDial = find.byType(SpeedDial);
        final findList = find.byType(ListView);
        final findSaveButton = find.byType(ElevatedButton);
        final findTitleField = find.byType(AppBarTextField);

        // Wait for the report to be created
        while (findAppBar.evaluate().isEmpty) {
          await Future.delayed(Duration(milliseconds: 100));
          await tester.pump();
        }

        expect(findAppBar, findsOneWidget);
        expect(findDial, findsOneWidget);
        expect(findList, findsOneWidget);
        expect(findSaveButton, findsOneWidget);
        expect(findTitleField, findsOneWidget);
      });
    },
  );
}
