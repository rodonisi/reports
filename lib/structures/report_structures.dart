// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';

class FieldOptions {
  FieldOptions({required this.title, required this.fieldType});
  final String title;
  final int fieldType;
}

class TextFieldOptions extends FieldOptions {
  TextFieldOptions(
      {required String title, required int fieldType, required this.lines})
      : super(title: title, fieldType: fieldType);
  final int lines;
}

class FieldData {
  FieldData({required this.text});

  String text;
}

class ReportLayout {
  ReportLayout({required this.name, required this.fields});

  final String name;
  final List<FieldOptions> fields;
}

class Report {
  const Report({required this.title, required this.layout, required this.data});

  final String title;
  final ReportLayout layout;
  final List<FieldData> data;

  toJSON() {
    Map<String, Object> jsonMap = {};
    for (var i = 0; i < layout.fields.length; i++) {
      jsonMap[layout.fields[i].title] = {
        'fieldType': layout.fields[i].fieldType,
        'fieldTitle': layout.fields[i].title,
        'data': data[i].text
      };
    }
    return json.encode(jsonMap);
  }
}
