import 'package:date_field/date_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/form_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities.dart';

class TapTestHandler {
  TapTestHandler() : _taps = 0;

  int _taps;

  int get taps => _taps;

  void increment() {
    _taps++;
  }
}

void main() async {
  late PreferencesModel model;

  setUp(() async {
    const dir = './test/resources';
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return dir;
    });
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    model = PreferencesModel();
    await model.initialize();
  });

  // ---------------------------------------------------------------------------
  // - Section Tests
  // ---------------------------------------------------------------------------
  group('Section form card', () {
    final title = 'section';
    final options = SectionFieldOptions(title: title);

    // --------------------
    group('builder', () {
      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be no wrapping card or title.
        expect(find.byType(Card), findsNothing);
        expect(find.byType(Text), findsNothing);

        // There should be one text field with section font size and the title
        // as text. The field should be enabled.
        final findTextField = find.byType(ControlledTextField);
        final textFieldWidget =
            findTextField.evaluate().first.widget as ControlledTextField;
        expect(findTextField, findsOneWidget);
        expect(
            textFieldWidget.style!.fontSize, SectionFieldOptions.sectionSize);
        expect(textFieldWidget.enabled, true);
        expect(find.text(title), findsOneWidget);

        // The remove icon should be visible.
        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });

      testWidgets('input interaction', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // The initial test should be the one given in the options constructor.
        expect(find.text(title), findsOneWidget);

        // Entering some new text should reflect on the widget.
        final testString = 'test';
        await tester.enterText(find.byType(TextField), testString);
        expect(find.text(title), findsNothing);
        expect(find.text(testString), findsOneWidget);
      });

      testWidgets('delete button interaction', (WidgetTester tester) async {
        final tapTestHandler = TapTestHandler();
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(
                options: options,
                onDelete: tapTestHandler.increment,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        final findDeleteButton = find.byIcon(Icons.cancel);

        // Initially there should be 0 registered taps.
        expect(tapTestHandler.taps, 0);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 1);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 2);
      });
    });

    // --------------------
    group('viewer', () {
      final data = TextFieldData(data: '');

      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(
                options: options,
                data: data,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // The delete icon should not be shown.
        expect(find.byIcon(Icons.cancel), findsNothing);
        // The text field should be present and disabled.
        final findTextField = find.byType(ControlledTextField);
        final textFieldWidgets =
            findTextField.evaluate().first.widget as ControlledTextField;
        expect(findTextField, findsOneWidget);
        expect(
            textFieldWidgets.style!.fontSize, SectionFieldOptions.sectionSize);
        expect(textFieldWidgets.enabled, false);
      });
    });
  });

  // -----------------------------------------------------------------------------
  // - Subsection Tests
  // -----------------------------------------------------------------------------
  group('Subsection form card', () {
    final title = 'subsection';
    final options = SectionFieldOptions(
      title: title,
      fontSize: SectionFieldOptions.subsectionSize,
    );

    group('builder', () {
      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be no wrapping card or title.
        expect(find.byType(Card), findsNothing);
        expect(find.byType(Text), findsNothing);

        // There should be one text field with subsection font size and the
        // title as text.
        final findTextField = find.byType(ControlledTextField);
        final textFieldWidget =
            findTextField.evaluate().first.widget as ControlledTextField;
        expect(findTextField, findsOneWidget);
        expect(textFieldWidget.style!.fontSize,
            SectionFieldOptions.subsectionSize);
        expect(textFieldWidget.enabled, true);
        expect(find.text(title), findsOneWidget);

        // The remove icon should be visible.
        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });

      testWidgets('input interaction', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // The initial test should be the one given in the options constructor.
        expect(find.text(title), findsOneWidget);

        // Entering some new text should reflect on the widget.
        final testString = 'test';
        await tester.enterText(find.byType(TextField), testString);
        expect(find.text(title), findsNothing);
        expect(find.text(testString), findsOneWidget);
      });

      testWidgets('delete button interaction', (WidgetTester tester) async {
        final tapTestHandler = TapTestHandler();
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              widget: FormCard(
                options: options,
                onDelete: tapTestHandler.increment,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        final findDeleteButton = find.byIcon(Icons.cancel);

        // Initially there should be 0 registered taps.
        expect(tapTestHandler.taps, 0);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 1);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 2);
      });
    });

    // --------------------
    group('viewer', () {
      final data = TextFieldData(data: '');

      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              widget: FormCard(
                options: options,
                data: data,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // The delete icon should not be shown.
        expect(find.byIcon(Icons.cancel), findsNothing);
        // The text field should be present and disabled.
        final findTextField = find.byType(ControlledTextField);
        final textFieldWidget =
            findTextField.evaluate().first.widget as ControlledTextField;
        expect(findTextField, findsOneWidget);
        expect(textFieldWidget.style!.fontSize,
            SectionFieldOptions.subsectionSize);
        expect(textFieldWidget.enabled, false);
      });
    });
  });

  // -----------------------------------------------------------------------------
  // - Text Field Tests
  // -----------------------------------------------------------------------------
  group('Text form card', () {
    final title = 'text';
    final options = TextFieldOptions(title: title);

    group('builder', () {
      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be a card wrapping the widget.
        expect(find.byType(Card), findsOneWidget);

        // There should be a text widget containing the title.
        expect(find.byType(Text), findsOneWidget);
        expect(find.text(title), findsOneWidget);

        // There should be one text field and it should be disabled.
        final findTextField = find.byType(ControlledTextField);
        final textFieldWidget =
            findTextField.evaluate().first.widget as ControlledTextField;
        expect(findTextField, findsOneWidget);
        expect(textFieldWidget.enabled, false);

        // There should be one delete button
        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });

      testWidgets('builder interaction', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // The date fields are diplayed in the initial state.
        expect(find.byType(TextField), findsOneWidget);

        // Tapping anywhere on the card should toggle the options menu.
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // There should be any date field anymore.
        expect(find.byType(TextField), findsNWidgets(2));
        // There are 7 text widgets: 4 titles and 3 for the mode picker.
        expect(find.byType(Text), findsNWidgets(4));
        // There's one switch for the display total option.
        expect(find.byType(Switch), findsOneWidget);

        // Tapping again outside any interactive widget should bring back to the
        // default state.
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('delete button interaction', (WidgetTester tester) async {
        final tapTestHandler = TapTestHandler();
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: tapTestHandler.increment,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        final findDeleteButton = find.byIcon(Icons.cancel);

        // Initially there should be 0 registered taps.
        expect(tapTestHandler.taps, 0);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 1);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 2);
      });
    });

    // --------------------
    group('viewer', () {
      final dataString = 'test';
      TextFieldData data = TextFieldData(data: '');
      late PreferencesModel model;

      setUp(() async {
        data = TextFieldData(data: dataString);
        model = PreferencesModel();
        await model.initialize();
      });

      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(
                options: options,
                data: data,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be a card wrapping the widget.
        expect(find.byType(Card), findsOneWidget);

        // There should be a text widget containing the title.
        expect(find.byType(Text), findsOneWidget);
        expect(find.text(title), findsOneWidget);

        // There should be one text field and it should be enabled with text
        // matching the data.
        final findTextField = find.byType(ControlledTextField);
        final textFieldWidget =
            findTextField.evaluate().first.widget as ControlledTextField;
        expect(findTextField, findsOneWidget);
        expect(textFieldWidget.enabled, true);
        expect(find.text(dataString), findsOneWidget);

        // There should be no delete button
        expect(find.byType(IconButton), findsNothing);
        expect(find.byIcon(Icons.cancel), findsNothing);
      });

      testWidgets('text field interaction', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(
                options: options,
                data: data,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        final findTextField = find.byType(ControlledTextField);

        // The initial displayed data should match the initialized state.
        expect(findTextField, findsOneWidget);
        expect(find.text(dataString), findsOneWidget);
        expect(data.data, dataString);

        await tester.enterText(findTextField, 'test2');
        await tester.pumpAndSettle();

        // Updating the text should update the displayed text and the data.
        expect(find.text(dataString), findsNothing);
        expect(find.text('test2'), findsOneWidget);
        expect(data.data, 'test2');
      });
    });
  });

  // -----------------------------------------------------------------------------
  // - Date Field Tests
  // -----------------------------------------------------------------------------
  group('Date form card', () {
    final title = 'date';
    final options = DateFieldOptions(title: title);

    // --------------------
    group('builder', () {
      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be a card wrapping the widget.
        expect(find.byType(Card), findsOneWidget);

        // There should be a text widget containing the title and a second, part
        // of the date field.
        expect(find.byType(Text), findsNWidgets(2));
        expect(find.text(title), findsOneWidget);

        // There should be one date field and it should be disabled.
        final findDateField = find.byType(DateTimeField);
        final dateFieldWidget =
            findDateField.evaluate().first.widget as DateTimeField;
        expect(findDateField, findsOneWidget);
        expect(dateFieldWidget.enabled, false);

        // There should be one delete button
        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });

      testWidgets('builder interaction', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // The date fields are diplayed in the initial state.
        expect(find.byType(DateTimeField), findsOneWidget);

        // Tapping anywhere on the card should toggle the options menu.
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // There should be any date field anymore.
        expect(find.byType(DateTimeField), findsNothing);
        // There are 6 text widgets: 3 titles and 3 for the mode picker.
        expect(find.byType(Text), findsNWidgets(6));
        // There's one text field for the title.
        expect(find.byType(TextField), findsOneWidget);

        // Tapping again outside any interactive widget should bring back to the
        // default state.
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        expect(find.byType(DateTimeField), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
      });
      testWidgets('delete button interaction', (WidgetTester tester) async {
        final tapTestHandler = TapTestHandler();

        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: tapTestHandler.increment,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        final findDeleteButton = find.byIcon(Icons.cancel);

        // Initially there should be 0 registered taps.
        expect(tapTestHandler.taps, 0);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 1);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 2);
      });
    });

    // --------------------
    group('viewer', () {
      final dataDate = DateTime.now();
      var data = DateFieldData(data: dataDate);

      setUp(() {
        data = DateFieldData(data: dataDate);
      });

      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(options: options, data: data),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be a card wrapping the widget.
        expect(find.byType(Card), findsOneWidget);

        // There should be a text widget containing the title and a second, part
        // of the date field.
        expect(find.byType(Text), findsNWidgets(2));
        expect(find.text(title), findsOneWidget);

        // There should be one date field
        final findDateField = find.byType(DateTimeField);
        final dateFieldWidget =
            findDateField.evaluate().first.widget as DateTimeField;
        expect(findDateField, findsOneWidget);
        expect(dateFieldWidget.enabled, true);
        expect(dateFieldWidget.selectedDate, dataDate);

        // There should be no delete button
        expect(find.byType(IconButton), findsNothing);
        expect(find.byIcon(Icons.cancel), findsNothing);
      });
    });
  });

  // -----------------------------------------------------------------------------
  // - Date Range Field Tests
  // -----------------------------------------------------------------------------
  group('Date range form card', () {
    final title = 'date_range';
    final options = DateRangeFieldOptions(title: title);

    // --------------------
    group('builder', () {
      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be a card wrapping the widget.
        expect(find.byType(Card), findsOneWidget);

        // There should be a text widget containing the title, two more in the
        // date fields, one separating the text field, and two for the hours
        // summary.
        expect(find.byType(Text), findsNWidgets(6));
        expect(find.text(title), findsOneWidget);

        // There should be two date fields that should be disabled.
        final findDateField = find.byType(DateTimeField);
        final dateFieldWidget =
            findDateField.evaluate().first.widget as DateTimeField;
        final dateFieldWidget1 =
            findDateField.evaluate().first.widget as DateTimeField;
        expect(findDateField, findsNWidgets(2));
        expect(dateFieldWidget.enabled, false);
        expect(dateFieldWidget1.enabled, false);

        // There should be one delete button
        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      });
      testWidgets('builder interaction', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        // The date fields are diplayed in the initial state.
        expect(find.byType(DateTimeField), findsNWidgets(2));

        // Tapping anywhere on the card should toggle the options menu.
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        // There should be any date field anymore.
        expect(find.byType(DateTimeField), findsNothing);
        // There are 8 text widgets: 3 titles, 3 for the mode picker and 2 for
        // the toggle tiles.
        expect(find.byType(Text), findsNWidgets(8));
        // There's one text field for the title.
        expect(find.byType(TextField), findsOneWidget);
        // There are 2 switches for the display total option and statistics
        // inclusion option.
        expect(find.byType(Switch), findsNWidgets(2));

        // Tapping again outside any interactive widget should bring back to the
        // default state.
        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        expect(find.byType(DateTimeField), findsNWidgets(2));
        expect(find.byType(TextField), findsNothing);
      });
      testWidgets('delete button interaction', (WidgetTester tester) async {
        final tapTestHandler = TapTestHandler();

        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapLocalized(
              widget: FormCard(
                options: options,
                onDelete: tapTestHandler.increment,
              ),
            ),
          );
          await tester.pumpAndSettle();
        });

        final findDeleteButton = find.byIcon(Icons.cancel);

        // Initially there should be 0 registered taps.
        expect(tapTestHandler.taps, 0);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 1);

        // Tapping should increment the counter.
        await tester.tap(findDeleteButton);
        await tester.pumpAndSettle();
        expect(tapTestHandler.taps, 2);
      });
    });

    // --------------------
    group('viewer', () {
      final dataDate = DateTime.now();
      var data = DateRangeFieldData(start: dataDate, end: dataDate);

      setUp(() {
        data = DateRangeFieldData(start: dataDate, end: dataDate);
      });

      testWidgets('layout', (WidgetTester tester) async {
        // Required for the localization to properly initialize.
        await tester.runAsync(() async {
          await tester.pumpWidget(
            WrapProviders(
              preferencesModel: model,
              widget: FormCard(options: options, data: data),
            ),
          );
          await tester.pumpAndSettle();
        });

        // There should be a card wrapping the widget.
        expect(find.byType(Card), findsOneWidget);

        // There should be a text widget containing the title and a second, part
        // of the date field.
        expect(find.byType(Text), findsNWidgets(6));
        expect(find.text(title), findsOneWidget);

        // There should be two date fields with the respective data set.
        final findDateField = find.byType(DateTimeField);
        final dateFieldWidget =
            findDateField.evaluate().first.widget as DateTimeField;
        final dateFieldWidget1 =
            findDateField.evaluate().first.widget as DateTimeField;
        expect(findDateField, findsNWidgets(2));
        expect(dateFieldWidget.enabled, true);
        expect(dateFieldWidget1.enabled, true);
        expect(dateFieldWidget.selectedDate, dataDate);
        expect(dateFieldWidget1.selectedDate, dataDate);

        // There should be no delete button
        expect(find.byType(IconButton), findsNothing);
        expect(find.byIcon(Icons.cancel), findsNothing);
      });
    });
  });
}
