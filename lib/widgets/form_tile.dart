// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reports/common/report_structures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  Widget _getField() {
    switch (widget.options.fieldType) {
      case FieldTypes.section:
        final secOpts = widget.options as SectionFieldOptions;
        return ControlledTextField(
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
      case FieldTypes.textField:
        final textOpts = widget.options as TextFieldOptions;
        final TextFieldData textData =
            widget.data as TextFieldData? ?? TextFieldData(data: '');
        return ControlledTextField(
          onChanged: (value) => textData.data = value,
          enabled: widget.enabled,
          maxLines: textOpts.lines,
          initialValue: textData.data,
          keyboardType:
              textOpts.numeric ? TextInputType.number : TextInputType.text,
        );
      case FieldTypes.date:
        final dateOpts = widget.options as DateFieldOptions;
        final DateFieldData dateData = widget.data as DateFieldData? ??
            DateFieldData(data: DateTime.now());

        return DateTimeField(
          onDateSelected: (value) => setState(() => dateData.data = value),
          selectedDate: dateData.data,
          enabled: widget.enabled,
          dateFormat: dateOpts.getFormat,
          mode: DateTimeFieldPickerMode.date,
        );
      default:
        throw ArgumentError.value(
            widget.options.fieldType, 'unsupported field type');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      localization.layoutFieldOptionsTitle,
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
            context, options, localization.layoutTextFieldOptionsHeader),
        SizedBox(
          height: 16.0,
        ),
        Text(
          localization.layoutTextFieldOptionsLines,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ControlledTextField(
          initialValue: options.lines.toString(),
          onChanged: (value) => options.lines = int.parse(value),
          keyboardType: TextInputType.number,
        ),
        _SwitchOption(
          title: localization.layoutTextFieldOptionsNumeric,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._getCommonOptions(context, widget.options, 'Date Field Options'),
        SizedBox(
          height: 20.0,
        ),
        Text(
          'Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: widget.options.mode,
          underline: Container(color: Colors.grey, height: 1.0),
          items: [
            DropdownMenuItem(
              child: Text('Date'),
              value: DateFieldFormats.dateModeID,
            ),
            DropdownMenuItem(
              child: Text('Time'),
              value: DateFieldFormats.timeModeID,
            ),
            DropdownMenuItem(
              child: Text('Date and Time'),
              value: DateFieldFormats.dateTimeModeID,
            )
          ],
          onChanged: (value) => setState(() => widget.options.mode = value!),
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
