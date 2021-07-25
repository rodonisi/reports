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

  final String dateLayoutJSON =
      '{"layout_name":"layout","0":{"field_name":"date","field_type":"date_field","mode":"date"}}';
  final dateLayout = ReportLayout(
    name: 'layout',
    fields: [
      DateFieldOptions(
        title: 'date',
        mode: DateFieldFormats.dateModeID,
      )
    ],
  );

  final String dateRangeLayoutJSON =
      '{"layout_name":"layout","0":{"field_name":"daterange","field_type":"date_range_field","mode":"date_and_time"}}';
  final dateRangeLayout = ReportLayout(
    name: 'layout',
    fields: [
      DateRangeFieldOptions(
        title: 'daterange',
        mode: DateFieldFormats.dateTimeModeID,
      )
    ],
  );

  final String simpleReportJSON =
      '{"report_title":"report","0":{"field_name":"field","field_type":"text_field","lines":1,"numeric":false,"data":"value"}}';
  final simpleReport = Report(
      title: 'report',
      layout: simpleLayout,
      data: [TextFieldData(data: 'value')]);

  final String dateReportJSON =
      '{"report_title":"report","0":{"field_name":"date","field_type":"date_field","mode":"date","data":"2021-07-20 00:28:23.288288"}}';
  final dateReport = Report(title: 'report', layout: dateLayout, data: [
    DateFieldData(data: DateTime.parse('2021-07-20 00:28:23.288288'))
  ]);

  final String dateRangeReportJSON =
      '{"report_title":"report","0":{"field_name":"daterange","field_type":"date_range_field","mode":"date_and_time","data":{"start":"2021-07-25 19:21:27.038217","end":"2021-07-25 19:21:27.038219"}}}';
  final dateRangeReport =
      Report(title: 'report', layout: dateRangeLayout, data: [
    DateRangeFieldData(
        start: DateTime.parse('2021-07-25 19:21:27.038217'),
        end: DateTime.parse('2021-07-25 19:21:27.038219'))
  ]);

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
    test('date field layout', () {
      expect(dateLayout.toJSON(), dateLayoutJSON);
    });
    test('date field layout', () {
      expect(ReportLayout.fromJSON(dateLayoutJSON).toJSON(), dateLayoutJSON);
    });
    test('date range field layout', () {
      expect(dateRangeLayout.toJSON(), dateRangeLayoutJSON);
    });
    test('roudntrip date range field layout', () {
      expect(ReportLayout.fromJSON(dateRangeLayoutJSON).toJSON(),
          dateRangeLayoutJSON);
    });
  });

  group('report tests', () {
    test('encode report', () {
      expect(simpleReport.toJSON(), simpleReportJSON);
    });
    test('roundtrip report', () {
      expect(Report.fromJSON(simpleReportJSON).toJSON(), simpleReportJSON);
    });
    test('date report', () {
      expect(dateReport.toJSON(), dateReportJSON);
    });
    test('roundtrip date', () {
      expect(Report.fromJSON(dateReportJSON).toJSON(), dateReportJSON);
    });
    test('date range report', () {
      expect(dateRangeReport.toJSON(), dateRangeReportJSON);
    });
    test('roundtrip date range', () {
      expect(
          Report.fromJSON(dateRangeReportJSON).toJSON(), dateRangeReportJSON);
    });
  });
}
