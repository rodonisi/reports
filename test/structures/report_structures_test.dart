import 'package:flutter_test/flutter_test.dart';

import 'package:reports/common/report_structures.dart';

void main() {
  final String simpleLayoutJSON =
      '{"layout_name":"layout","0":{"field_name":"field","field_type":0,"lines":1,"numeric":false}}';
  final simpleLayout = ReportLayout(
    name: 'layout',
    fields: [TextFieldOptions(title: 'field', lines: 1, numeric: false)],
  );
  final String simpleReportJSON =
      '{"report_title":"report","0":{"field_name":"field","field_type":0,"lines":1,"numeric":false,"data":"value"}}';
  final simpleReport = Report(
      title: 'report',
      layout: simpleLayout,
      data: [TextFieldData(data: 'value')]);

  group('layout tests', () {
    test('encode layout', () {
      final layout = ReportLayout(
        name: 'layout',
        fields: [TextFieldOptions(title: 'field', lines: 1, numeric: false)],
      );
      expect(layout.toJSON(), simpleLayoutJSON);
    });
    test('roundtrip layout', () {
      expect(
          ReportLayout.fromJSON(simpleLayoutJSON).toJSON(), simpleLayoutJSON);
    });
  });

  group('report tests', () {
    test('encode report', () {
      expect(simpleReport.toJSON(), simpleReportJSON);
    });
    test('roundtrip report', () {
      expect(Report.fromJSON(simpleReportJSON).toJSON(), simpleReportJSON);
    });
  });
}
