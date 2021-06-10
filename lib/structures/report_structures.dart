import 'dart:convert';

class FieldOptions {
  FieldOptions({this.title, this.fieldType});
  final String title;
  final int fieldType;
}

class TextFieldOptions extends FieldOptions {
  TextFieldOptions({String title, int fieldType, this.lines})
      : super(title: title, fieldType: fieldType);
  final int lines;
}

class FieldData {
  FieldData({this.text});

  String text;
}

class ReportLayout {
  ReportLayout({this.name, this.fields});

  final String name;
  final List<FieldOptions> fields;
}

class Report {
  const Report({this.title, this.layout, this.data});

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
