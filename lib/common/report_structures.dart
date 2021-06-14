// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';

class FieldOptions {
  static const String nameID = 'field_name';
  static const String typeID = 'field_type';

  String title;
  int fieldType;

  FieldOptions({required this.title, required this.fieldType});

  FieldOptions.fromMap(Map<String, dynamic> map)
      : title = map[nameID],
        fieldType = map[typeID];

  Map<String, dynamic> asMap() {
    final Map<String, dynamic> map = {};
    map[nameID] = title;
    map[typeID] = fieldType;

    return map;
  }
}

class TextFieldOptions extends FieldOptions {
  static const String linesID = 'lines';

  int lines;

  TextFieldOptions({String title = 'Text', this.lines = 1})
      : super(title: title, fieldType: 0);

  TextFieldOptions.fromMap(Map<String, dynamic> map)
      : lines = map[linesID],
        super.fromMap(map);

  @override
  Map<String, dynamic> asMap() {
    final map = super.asMap();
    map[linesID] = lines;

    return map;
  }
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
          final FieldOptions options;
          switch (value[FieldOptions.typeID]) {
            case 0:
              options = TextFieldOptions.fromMap(fieldMap);
              break;
            default:
              throw ArgumentError.value(value[FieldOptions.typeID].fieldType,
                  'unsupported field type');
          }
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
    serialized[i.toString()] = layout.fields[i].asMap();
    if (data != null)
      (serialized[i.toString()]! as Map<String, dynamic>)[FieldData.dataID] =
          data[i].text;
  }

  return serialized;
}
