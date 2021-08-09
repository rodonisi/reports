// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/widgets/controlled_text_field.dart';

// -----------------------------------------------------------------------------
// - FormTileContent Widget Implementation
// -----------------------------------------------------------------------------

/// Creates the form card content for the given type.
class FormTileContent extends StatefulWidget {
  const FormTileContent({
    Key? key,
    required this.options,
    this.enabled = true,
    this.data,
  }) : super(key: key);

  final FieldOptions options;
  final FieldData? data;
  final bool enabled;

  @override
  _FormTileContentState createState() => _FormTileContentState();
}

class _FormTileContentState extends State<FormTileContent> {
  late bool _enabled;

  Widget _getSectionField() {
    final secOpts = widget.options as SectionFieldOptions;
    return ControlledTextField(
      key: ObjectKey(secOpts),
      enabled: widget.enabled,
      initialValue: secOpts.title,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      style: TextStyle(
        fontSize: secOpts.fontSize,
        fontWeight: FontWeight.bold,
      ),
      onChanged: (val) => secOpts.title = val,
    );
  }

  Widget _getTextField() {
    final textOpts = widget.options as TextFieldOptions;
    final TextFieldData textData =
        widget.data as TextFieldData? ?? TextFieldData(data: '');
    return ControlledTextField(
      key: ObjectKey(textOpts),
      onChanged: (value) => textData.data = value,
      enabled: _enabled,
      maxLines: textOpts.lines,
      initialValue: textData.data,
      keyboardType:
          textOpts.numeric ? TextInputType.number : TextInputType.text,
    );
  }

  Widget _getDateField() {
    final dateOpts = widget.options as DateFieldOptions;
    final DateFieldData dateData =
        widget.data as DateFieldData? ?? DateFieldData(data: DateTime.now());

    return DateTimeField(
      key: ObjectKey(dateOpts),
      onDateSelected: (value) => setState(() => dateData.data = value),
      selectedDate: dateData.data,
      enabled: _enabled,
      dateFormat: dateOpts.getFormat,
      mode: DateFieldFormats.getDateTimeFieldPickerMode(dateOpts.mode),
    );
  }

  Widget _getDateRangeField() {
    final dateRangeOpts = widget.options as DateRangeFieldOptions;
    final DateRangeFieldData dateRangeData =
        widget.data as DateRangeFieldData? ?? DateRangeFieldData.empty();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          key: ObjectKey(dateRangeOpts),
          children: [
            Expanded(
              child: DateTimeField(
                onDateSelected: (value) => setState(() {
                  // Adjust end date if start is after end.
                  if (value.isAfter(dateRangeData.end))
                    dateRangeData.end =
                        dateRangeData.end.add(Duration(days: 1));

                  dateRangeData.start = value;
                }),
                selectedDate: dateRangeData.start,
                enabled: _enabled,
                dateFormat: dateRangeOpts.getFormat,
                mode: DateFieldFormats.getDateTimeFieldPickerMode(
                    dateRangeOpts.mode),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('-'),
            ),
            Expanded(
              child: DateTimeField(
                onDateSelected: (value) => setState(() {
                  // Adjust end date if start is after end.
                  if (dateRangeData.start.isAfter(value))
                    dateRangeData.end = value.add(Duration(days: 1));
                  else
                    dateRangeData.end = value;
                }),
                selectedDate: dateRangeData.end,
                enabled: _enabled,
                dateFormat: dateRangeOpts.getFormat,
                mode: DateFieldFormats.getDateTimeFieldPickerMode(
                    dateRangeOpts.mode),
              ),
            ),
          ],
        ),
        if (dateRangeOpts.showTotal)
          SizedBox(
            height: 8.0,
          ),
        if (dateRangeOpts.showTotal)
          Row(
            children: [
              Text(
                'Total hours: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(dateRangeData.end
                  .difference(dateRangeData.start)
                  .inHours
                  .toString()),
            ],
          ),
      ],
    );
  }

  Widget _getField() {
    switch (widget.options.fieldType) {
      case FieldTypes.section:
        return _getSectionField();
      case FieldTypes.textField:
        return _getTextField();
      case FieldTypes.date:
        return _getDateField();
      case FieldTypes.dateRange:
        return _getDateRangeField();
      default:
        throw ArgumentError.value(
            widget.options.fieldType, 'unsupported field type');
    }
  }

  @override
  Widget build(BuildContext context) {
    _enabled = widget.enabled && !context.read<PreferencesModel>().readerMode;

    if (widget.options is SectionFieldOptions) return _getField();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.options.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _getField()
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// - FormTileOptions Widget Implementation
// -----------------------------------------------------------------------------

/// Creates the options for the form card of the given type.
class FormTileOptions extends StatelessWidget {
  const FormTileOptions({Key? key, required this.options}) : super(key: key);

  final FieldOptions options;

  @override
  Widget build(BuildContext context) {
    switch (options.fieldType) {
      case FieldTypes.textField:
        return _TextFieldTileOptions(
          options: options as TextFieldOptions,
        );
      case FieldTypes.date:
        return _DateFieldTileOptions(
          options: options as DateFieldOptions,
        );
      case FieldTypes.dateRange:
        return _DateRangeFieldTileOptions(
          options: options as DateRangeFieldOptions,
        );
      default:
        throw ArgumentError.value(options.fieldType, 'unsupported field type');
    }
  }
}

List<Widget> _getCommonOptions(
    BuildContext context, FieldOptions options, String title) {
  final localization = AppLocalizations.of(context)!;
  final opts = [
    Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    ),
    Divider(),
    Text(
      localization.title,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    ControlledTextField(
      initialValue: options.title,
      onChanged: (value) => options.title = value,
    ),
  ];

  return opts;
}

class _TextFieldTileOptions extends StatelessWidget {
  _TextFieldTileOptions({Key? key, required this.options}) : super(key: key);

  final TextFieldOptions options;
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._getCommonOptions(
            context, options, localization.textFieldOptionsHeader),
        SizedBox(
          height: 16.0,
        ),
        Text(
          localization.lines,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ControlledTextField(
          initialValue: options.lines.toString(),
          onChanged: (value) => options.lines = int.parse(value),
          keyboardType: TextInputType.number,
        ),
        _SwitchOption(
          title: localization.numericKeyboard,
          getter: options.getNumeric,
          setter: options.setNumeric,
        ),
      ],
    );
  }
}

class _DateFieldTileOptions extends StatefulWidget {
  _DateFieldTileOptions({Key? key, required this.options}) : super(key: key);

  final DateFieldOptions options;

  @override
  __DateFieldTileOptionsState createState() => __DateFieldTileOptionsState();
}

class __DateFieldTileOptionsState extends State<_DateFieldTileOptions> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._getCommonOptions(
            context, widget.options, localizations.dateFieldOptionsHeader),
        SizedBox(
          height: 20.0,
        ),
        Text(
          localizations.mode,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: widget.options.mode,
          underline: Container(color: Colors.grey, height: 1.0),
          items: [
            DropdownMenuItem(
              child: Text(localizations.date),
              value: DateFieldFormats.dateModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.time),
              value: DateFieldFormats.timeModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.dateAndTime),
              value: DateFieldFormats.dateTimeModeID,
            )
          ],
          onChanged: (value) => setState(() => widget.options.mode = value!),
        ),
      ],
    );
  }
}

class _DateRangeFieldTileOptions extends StatefulWidget {
  _DateRangeFieldTileOptions({Key? key, required this.options})
      : super(key: key);

  final DateRangeFieldOptions options;

  @override
  __DateRangeFieldTileOptionsState createState() =>
      __DateRangeFieldTileOptionsState();
}

class __DateRangeFieldTileOptionsState
    extends State<_DateRangeFieldTileOptions> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._getCommonOptions(
            context, widget.options, localizations.dateFieldOptionsHeader),
        SizedBox(
          height: 20.0,
        ),
        Text(
          localizations.mode,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: widget.options.mode,
          underline: Container(color: Colors.grey, height: 1.0),
          items: [
            DropdownMenuItem(
              child: Text(localizations.date),
              value: DateFieldFormats.dateModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.time),
              value: DateFieldFormats.timeModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.dateAndTime),
              value: DateFieldFormats.dateTimeModeID,
            )
          ],
          onChanged: (value) => setState(() => widget.options.mode = value!),
        ),
        _SwitchOption(
          title: 'Show total hours',
          getter: () => widget.options.showTotal,
          setter: (value) => widget.options.showTotal = value,
        ),
      ],
    );
  }
}

class _SwitchOption extends StatefulWidget {
  _SwitchOption({
    Key? key,
    required this.title,
    required this.getter,
    required this.setter,
  }) : super(key: key);

  final String title;
  final getter;
  final setter;

  @override
  __SwitchOptionState createState() => __SwitchOptionState();
}

class __SwitchOptionState extends State<_SwitchOption> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Switch.adaptive(
            value: widget.getter(),
            onChanged: (val) {
              setState(() {
                widget.setter(val);
              });
            })
      ],
    );
  }
}
