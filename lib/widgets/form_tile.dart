// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reports/common/report_structures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/widgets/controlled_text_field.dart';

// -----------------------------------------------------------------------------
// - FormTileContent Widget Implementation
// -----------------------------------------------------------------------------

/// Creates the form card content for the given type.
class FormTileContent extends StatelessWidget {
  const FormTileContent(
      {Key? key, required this.options, this.enabled = true, this.controller})
      : super(key: key);

  final FieldOptions options;
  final bool enabled;
  final TextEditingController? controller;

  Widget _getField() {
    switch (options.fieldType) {
      case FieldTypes.section:
        final secOpts = options as SectionFieldOptions;
        return ControlledTextField(
          enabled: enabled,
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
        final textOpts = options as TextFieldOptions;
        return TextField(
          enabled: enabled,
          maxLines: textOpts.lines,
          controller: controller,
          keyboardType:
              textOpts.numeric ? TextInputType.number : TextInputType.text,
        );
      default:
        throw ArgumentError.value(options.fieldType, 'unsupported field type');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (options is SectionFieldOptions) return _getField();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          options.title,
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
      default:
        throw ArgumentError.value(options.fieldType, 'unsupported field type');
    }
  }
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
        Text(
          localization.layoutTextFieldOptionsHeader,
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
        Container(
          height: 20.0,
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
