// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';
import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

// -----------------------------------------------------------------------------
// - Field Types
// -----------------------------------------------------------------------------

/// Contains all the field types keys.
class FieldTypes {
  static const String textField = 'text_field';
  static const String section = 'section';
  static const String date = 'date_field';
  static const String dateRange = 'date_range_field';
}

// -----------------------------------------------------------------------------
// - Options Structures
// -----------------------------------------------------------------------------

/// Base class to store field options. Contains all the options common for all
/// the types of fields. Each extending class has to implement `fromMap` and
/// `toMap` methods to convert the options to JSON.
abstract class FieldOptions {
  static const String nameID = 'field_name';
  static const String typeID = 'field_type';

  String title;
  String fieldType;

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

/// Representation of the options specific to a text field.
class TextFieldOptions extends FieldOptions {
  static const String linesID = 'lines';
  static const String numericID = 'numeric';

  int lines;
  bool numeric;

  TextFieldOptions(
      {required String title, this.lines = 1, this.numeric = false})
      : super(title: title, fieldType: FieldTypes.textField);

  bool getNumeric() {
    return numeric;
  }

  void setNumeric(bool value) {
    numeric = value;
  }

  TextFieldOptions.fromMap(Map<String, dynamic> map)
      : lines = map[linesID],
        numeric = map[numericID],
        super.fromMap(map);

  @override
  Map<String, dynamic> asMap() {
    final map = super.asMap();
    map[linesID] = lines;
    map[numericID] = numeric;

    return map;
  }
}

/// Representation of the options specific to a section field.
class SectionFieldOptions extends FieldOptions {
  static const String fontSizeID = 'font_size';
  static const double sectionSize = 32.0;
  static const double subsectionSize = 20.0;

  SectionFieldOptions({required String title, this.fontSize = sectionSize})
      : super(title: title, fieldType: FieldTypes.section);
  final fontSize;

  SectionFieldOptions.fromMap(Map<String, dynamic> map)
      : fontSize = map[fontSizeID],
        super.fromMap(map);

  @override
  Map<String, dynamic> asMap() {
    final map = super.asMap();
    map[fontSizeID] = fontSize;

    return map;
  }
}

/// Contains the supported date formats and IDs for the date field.
class DateFieldFormats {
  static const String dateModeID = 'date';
  static const String timeModeID = 'time';
  static const String dateTimeModeID = 'date_and_time';

  static DateFormat getFormat(String mode) {
    final locale = Platform.localeName;
    switch (mode) {
      case dateModeID:
        return DateFormat.yMMMMd(locale);
      case timeModeID:
        return DateFormat.jm(locale);
      case dateTimeModeID:
        return DateFormat.yMMMd(locale).add_jm();
      default:
        throw Exception('Unsupported mode $mode');
    }
  }

  static DateTimeFieldPickerMode getDateTimeFieldPickerMode(String mode) {
    switch (mode) {
      case dateModeID:
        return DateTimeFieldPickerMode.date;
      case timeModeID:
        return DateTimeFieldPickerMode.time;
      case dateTimeModeID:
        return DateTimeFieldPickerMode.dateAndTime;
      default:
        throw Exception('Unsupported mode $mode');
    }
  }
}

/// Representation of the options specific to a date field.
class DateFieldOptions extends FieldOptions {
  static const String modeID = 'mode';
  DateFieldOptions({
    required String title,
    this.mode = DateFieldFormats.dateModeID,
  }) : super(title: title, fieldType: FieldTypes.date);

  /// The date field mode. Must be one of the IDs defined in the
  /// DateFieldFormats class.
  String mode;

  DateFieldOptions.fromMap(Map<String, dynamic> map)
      : mode = map[modeID],
        super.fromMap(map);

  /// Get the DateFormat class from the current mode.
  DateFormat get getFormat {
    return DateFieldFormats.getFormat(mode);
  }

  @override
  Map<String, dynamic> asMap() {
    final map = super.asMap();
    map[modeID] = mode;

    return map;
  }
}

/// Representation of the options specific to a date range field.
class DateRangeFieldOptions extends FieldOptions {
  static const String modeID = 'mode';
  static const String showTotalID = 'show_total';

  DateRangeFieldOptions({
    required String title,
    this.mode = DateFieldFormats.timeModeID,
    this.showTotal = true,
  }) : super(title: title, fieldType: FieldTypes.dateRange);

  /// The date field mode. Must be one of the IDs defined in the
  /// DateFieldFormats class.
  String mode;

  /// Wheter to show the total amount of hours of the date range field.
  bool showTotal;

  DateRangeFieldOptions.fromMap(Map<String, dynamic> map)
      : mode = map[modeID],
        showTotal = map[showTotalID],
        super.fromMap(map);

  /// Get the DateFormat class from the current mode.
  DateFormat get getFormat {
    return DateFieldFormats.getFormat(mode);
  }

  @override
  Map<String, dynamic> asMap() {
    final map = super.asMap();
    map[modeID] = mode;
    map[showTotalID] = showTotal;

    return map;
  }
}

// -----------------------------------------------------------------------------
// - Field Data Structures
// -----------------------------------------------------------------------------

/// Base class for a field's data
abstract class FieldData {
  static const String dataID = 'data';

  /// Default constructor.
  FieldData();

  /// Construct a FieldData object from some data.
  FieldData.fromData(dynamic data);

  /// Serialize the FieldData data to an encodable object.
  dynamic serialize();
}

/// Representation of text field's data.
class TextFieldData extends FieldData {
  String data;
  TextFieldData({required this.data});

  @override
  TextFieldData.fromData(this.data);

  @override
  String serialize() {
    return data;
  }
}

/// Representation of date field's data.
class DateFieldData extends FieldData {
  DateTime data;
  DateFieldData({required this.data});

  @override
  DateFieldData.fromData(String data) : this.data = DateTime.parse(data);

  @override
  serialize() {
    return data.toString();
  }
}

/// Representation of date range field's data.
class DateRangeFieldData extends FieldData {
  static const String startID = 'start';
  static const String endID = 'end';

  DateRangeFieldData({required DateTime start, required DateTime end})
      : start = start,
        end = end;

  @override
  DateRangeFieldData.fromData(Map<String, dynamic> data)
      : start = DateTime.parse(data[startID]!),
        end = DateTime.parse(data[endID]!);

  DateRangeFieldData.empty()
      : start = DateTime.now(),
        end = DateTime.now();

  DateTime start;
  DateTime end;

  @override
  Map<String, dynamic> serialize() {
    return {startID: start.toString(), endID: end.toString()};
  }
}

// -----------------------------------------------------------------------------
// - FileHeader keys
// -----------------------------------------------------------------------------

/// Contains the key for the file headers.
class FileHeader {
  static const String versionID = 'version';
  static const String typeID = 'type';
  static const String reportID = 'report';
  static const String layoutID = 'layout';
}

// -----------------------------------------------------------------------------
// - Layout Structure
// -----------------------------------------------------------------------------

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
            case FieldTypes.section:
              options = SectionFieldOptions.fromMap(fieldMap);
              break;
            case FieldTypes.textField:
              options = TextFieldOptions.fromMap(fieldMap);
              break;
            case FieldTypes.date:
              options = DateFieldOptions.fromMap(fieldMap);
              break;
            case FieldTypes.dateRange:
              options = DateRangeFieldOptions.fromMap(fieldMap);
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
  Future<String> toJSON() async {
    final packageInfo = await PackageInfo.fromPlatform();
    Map<String, dynamic> jsonMap = {};
    jsonMap[nameID] = name;
    jsonMap[FileHeader.versionID] = packageInfo.version;
    jsonMap[FileHeader.typeID] = FileHeader.layoutID;
    jsonMap.addAll(_serialize(layout: this));
    return jsonEncode(jsonMap);
  }
}

// -----------------------------------------------------------------------------
// - Report Structure
// -----------------------------------------------------------------------------

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

    // Set the layout name
    this.layout.name = jsonMap[FileHeader.layoutID];

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
          final mapData = getFieldData(
              fieldMap[FieldOptions.typeID], fieldMap[FieldData.dataID]);
          data.add(mapData);
        }
      }
    });
  }

  FieldData getFieldData(String fieldType, dynamic data) {
    switch (fieldType) {
      case FieldTypes.date:
        return DateFieldData.fromData(data);
      case FieldTypes.dateRange:
        return DateRangeFieldData.fromData(data);
      default:
        return TextFieldData.fromData(data);
    }
  }

  /// Convert the report to a JSON string.
  Future<String> toJSON() async {
    final packageInfo = await PackageInfo.fromPlatform();
    Map<String, dynamic> jsonMap = {};
    jsonMap[titleID] = title;
    jsonMap[FileHeader.versionID] = packageInfo.version;
    jsonMap[FileHeader.typeID] = FileHeader.reportID;
    jsonMap[FileHeader.layoutID] = layout.name;
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
          data[i].serialize();
  }

  return serialized;
}
