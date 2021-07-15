import 'package:flutter_test/flutter_test.dart';

import 'package:reports/common/report_structures.dart';

void main() {
  final String simpleLayoutJSON =
      '{"layout_name":"layout","0":{"field_name":"field","field_type":"text_field","lines":1,"numeric":false}}';
  final simpleLayout = ReportLayout(
    name: 'layout',
    fields: [TextFieldOptions(title: 'field', lines: 1, numeric: false)],
  );

  final String sectionLayoutJSON =
      '{"layout_name":"layout","0":{"field_name":"section","field_type":"section","font_size":32.0}}';
  final sectionLayout = ReportLayout(
    name: 'layout',
    fields: [SectionFieldOptions(title: 'section')],
  );

  final String subsectionLayoutJSON =
      '{"layout_name":"layout","0":{"field_name":"section","field_type":"section","font_size":20.0}}';
  final subsectionLayout = ReportLayout(
    name: 'layout',
    fields: [
      SectionFieldOptions(
        title: 'section',
        fontSize: SectionFieldOptions.subsectionSize,
      )
    ],
  );

  final String simpleReportJSON =
      '{"report_title":"report","0":{"field_name":"field","field_type":"text_field","lines":1,"numeric":false,"data":"value"}}';
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
    test('section layout', () {
      expect(sectionLayout.toJSON(), sectionLayoutJSON);
    });
    test('subsection layout', () {
      expect(subsectionLayout.toJSON(), subsectionLayoutJSON);
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
