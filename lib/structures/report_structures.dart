// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';

class FieldOptions {
  final String title;
  final int fieldType;
  FieldOptions({required this.title, required this.fieldType});

  static const String nameID = 'field_name';
  static const String typeID = 'field_type';
}

class TextFieldOptions extends FieldOptions {
  final int lines;
  TextFieldOptions(
      {required String title, required int fieldType, required this.lines})
      : super(title: title, fieldType: fieldType);
}

class FieldData {
  String text;
  FieldData({required this.text});

  static const String dataID = 'data';
}

class ReportLayout {
  String name;
  List<FieldOptions> fields;
  ReportLayout({required this.name, required this.fields});

  static const String nameID = 'layout_name';

  ReportLayout.fromJson(String jsonString)
      : this.name = '',
        this.fields = [] {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    jsonMap.forEach((key, value) {
      if (key == nameID)
        name = value as String;
      else {
        final index = int.tryParse(key);
        if (index != null) {
          final fieldMap = value as Map<String, dynamic>;
          final options = FieldOptions(
            title: fieldMap[FieldOptions.nameID]!,
            fieldType: fieldMap[FieldOptions.typeID]!,
          );
          fields.add(options);
        }
      }
    });
  }

  String toJSON() {
    Map<String, dynamic> jsonMap = {};
    jsonMap[nameID] = name;
    jsonMap.addAll(_serialize(layout: this));
    return jsonEncode(jsonMap);
  }
}

class Report {
  String title;
  ReportLayout layout;
  final List<FieldData> data;
  Report({required this.title, required this.layout, required this.data});

  static const String titleID = 'report_title';

  Report.fromJSON(String jsonString)
      : this.title = '',
        this.layout = ReportLayout.fromJson(jsonString),
        data = [] {
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    jsonMap.forEach((key, value) {
      if (key == titleID)
        this.title = value as String;
      else {
        final index = int.tryParse(key);
        if (index != null) {
          final fieldMap = value as Map<String, dynamic>;
          final mapData = FieldData(text: fieldMap[FieldData.dataID]!);
          data.add(mapData);
        }
      }
    });
  }

  String toJSON() {
    Map<String, dynamic> jsonMap = {};
    jsonMap['report_title'] = title;
    jsonMap.addAll(_serialize(layout: layout, data: data));

    return jsonEncode(jsonMap);
  }
}

Map<String, dynamic> _serialize(
    {required ReportLayout layout, List<FieldData>? data}) {
  Map<String, dynamic> serialized = {};

  for (var i = 0; i < layout.fields.length; i++) {
    serialized[i.toString()] = {
      FieldOptions.nameID: layout.fields[i].title,
      FieldOptions.typeID: layout.fields[i].fieldType,
    };
    if (data != null)
      (serialized[i.toString()]! as Map<String, dynamic>)[FieldData.dataID] =
          data[i].text;
  }

  return serialized;
}
