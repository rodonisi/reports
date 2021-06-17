// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';

/// Base class to store field options. Contains all the options common for all
/// the types of fields. Each extending class has to implement `fromMap` and
/// `toMap` methods to convert the options to JSON.
abstract class FieldOptions {
  static const String nameID = 'field_name';
  static const String typeID = 'field_type';

  String title;
  int fieldType;

  FieldOptions({required this.title, required this.fieldType});

  /// Convert the field options to a serializabel map.
  FieldOptions.fromMap(Map<String, dynamic> map)
      : title = map[nameID],
        fieldType = map[typeID];

  /// Initialize a FieldOptions instance from a JSON map.
  Map<String, dynamic> asMap() {
    final Map<String, dynamic> map = {};
    map[nameID] = title;
    map[typeID] = fieldType;

    return map;
  }
}

/// Class containing the options specific to a text field.
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

/// Base class for a field's data
abstract class FieldData {
  static const String dataID = 'data';

  String toString();
}

/// A text field's data.
class TextFieldData extends FieldData {
  String data;
  TextFieldData({required this.data});

  @override
  String toString() {
    return data;
  }
}

/// Representation of a report layout. A report layout always contains a name,
/// as well as a list of FieldOptions, representing the fields in the layout.
class ReportLayout {
  String name;
  List<FieldOptions> fields;
  ReportLayout({required this.name, required this.fields});

  static const String nameID = 'layout_name';

  /// Initialize a layout from a JSON string.
  ReportLayout.fromJSON(String jsonString)
      : this.name = '',
        this.fields = [] {
    // Decode the JSON string.
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    // Iterate over the decoded JSON map.
    jsonMap.forEach((key, value) {
      // Get the layout name.
      if (key == nameID)
        name = value as String;
      else {
        // Get a layout field.
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

  /// Convert the layout to a JSON string.
  String toJSON() {
    Map<String, dynamic> jsonMap = {};
    jsonMap[nameID] = name;
    jsonMap.addAll(_serialize(layout: this));
    return jsonEncode(jsonMap);
  }
}

/// Representation of a report. Each report contains a title, a layout, and some
/// data for each of the fields in the layout.
class Report {
  static const String titleID = 'report_title';

  String title;
  ReportLayout layout;
  final List<FieldData> data;
  Report({required this.title, required this.layout, required this.data});

  /// Initialize a report from a JSON string.
  Report.fromJSON(String jsonString)
      : this.title = '',
        this.layout = ReportLayout.fromJSON(jsonString),
        data = [] {
    // Decode the json string.
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    // Iterate over the decoded json map.
    jsonMap.forEach((key, value) {
      // Get the report title.
      if (key == titleID)
        this.title = value as String;
      else {
        // Get a field.
        final index = int.tryParse(key);
        if (index != null) {
          final fieldMap = value as Map<String, dynamic>;
          final mapData = TextFieldData(data: fieldMap[FieldData.dataID]!);
          data.add(mapData);
        }
      }
    });
  }

  /// Convert the report to a JSON string.
  String toJSON() {
    Map<String, dynamic> jsonMap = {};
    jsonMap['report_title'] = title;
    jsonMap.addAll(_serialize(layout: layout, data: data));

    return jsonEncode(jsonMap);
  }
}

/// Serialize a layout and its data (if present).
Map<String, dynamic> _serialize(
    {required ReportLayout layout, List<FieldData>? data}) {
  Map<String, dynamic> serialized = {};

  // Iterate over the layout fields.
  for (var i = 0; i < layout.fields.length; i++) {
    // Create a new nested map for the field options.
    serialized[i.toString()] = layout.fields[i].asMap();

    // Add the data to the nested map if present.
    if (data != null)
      (serialized[i.toString()]! as Map<String, dynamic>)[FieldData.dataID] =
          data[i].toString();
  }

  return serialized;
}
