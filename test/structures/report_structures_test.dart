import 'package:flutter_test/flutter_test.dart';

import 'package:reports/common/report_structures.dart';

void main() {
  final String simpleLayoutJSON =
      '{"layout_name":"layout","0":{"field_name":"field","field_type":0}}';
  final String simpleReportJSON =
      '{"report_title":"report","0":{"field_name":"field","field_type":0,"data":"value"}}';

  group('layout tests', () {
    test('encode layout', () {
      final layout = ReportLayout(
        name: 'layout',
        fields: [TextFieldOptions(title: 'field', lines: 1)],
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
      final layout = ReportLayout(
        name: 'layout',
        fields: [
          TextFieldOptions(
            title: 'field',
            lines: 1,
          )
        ],
      );
      final data = [TextFieldData(data: 'value')];
      final report = Report(title: 'report', layout: layout, data: data);
      expect(report.toJSON(), simpleReportJSON);
    });
    test('roundtrip layout', () {
      expect(Report.fromJSON(simpleReportJSON).toJSON(), simpleReportJSON);
    });
  });
}
