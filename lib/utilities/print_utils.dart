import 'package:easy_localization/easy_localization.dart';
import 'package:reports/common/report_structures.dart';

/// Print the given duration as a human-readable string.
String prettyDuration(Duration duration) {
  final StringBuffer buf = StringBuffer();
  if (duration.inDays != 0) {
    final days = duration.inDays;
    buf.write('${days}d ');
    duration -= Duration(days: days);
  }

  if (duration.inHours != 0) {
    final hours = duration.inHours;
    buf.write('${duration.inHours}h ');
    duration -= Duration(hours: hours);
  }

  buf.write('${duration.inMinutes}m ');

  return buf.toString().trim();
}

/// Print the given field type as a readable string.
String prettyFieldType(String fieldType) {
  switch (fieldType) {
    case FieldTypes.section:
      return 'builder.fields.section.header'.tr();
    case FieldTypes.textField:
      return 'builder.fields.text.header'.tr();
    case FieldTypes.date:
      return 'builder.fields.date.header'.tr();
    case FieldTypes.dateRange:
      return 'builder.fields.date_range.header'.tr();
    default:
      return 'invalid field type';
  }
}
