// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:reports/common/report_structures.dart';

// -----------------------------------------------------------------------------
// - FormTileContent Widget Implementation
// -----------------------------------------------------------------------------
class FormTileContent extends StatelessWidget {
  const FormTileContent(
      {Key? key, required this.options, this.enabled = true, this.controller})
      : super(key: key);

  final FieldOptions options;
  final bool enabled;
  final TextEditingController? controller;

  Widget _getField() {
    switch (options.fieldType) {
      case 0:
        final textOpts = options as TextFieldOptions;
        return TextField(
          enabled: enabled,
          maxLines: textOpts.lines,
          controller: controller,
        );
      default:
        throw ArgumentError.value(options.fieldType, 'unsupported field type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(options.title), _getField()],
    );
  }
}

// -----------------------------------------------------------------------------
// - FormTileOptions Widget Implementation
// -----------------------------------------------------------------------------
class FormTileOptions extends StatelessWidget {
  const FormTileOptions({Key? key, required this.options}) : super(key: key);

  final FieldOptions options;

  @override
  Widget build(BuildContext context) {
    switch (options.fieldType) {
      case 0:
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Field Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        Divider(),
        Text(
          'Field Title',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: options.title,
          onChanged: (value) => options.title = value,
        ),
        Container(
          height: 20.0,
        ),
        Text(
          'Lines',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          initialValue: options.lines.toString(),
          onChanged: (value) => options.lines = int.parse(value),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
