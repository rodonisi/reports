import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:reports/common/report_structures.dart';

// -----------------------------------------------------------------------------
// - Sample Layouts
// -----------------------------------------------------------------------------
const String simpleLayoutJSON =
    '{"layout_name":"layout","version":"1.0.0","type":"layout","0":{"field_name":"field","field_type":"text_field","statistics_include":false,"lines":1,"numeric":false}}';
final simpleLayout = ReportLayout(
  name: 'layout',
  fields: [TextFieldOptions(title: 'field', lines: 1, numeric: false)],
);

const String sectionLayoutJSON =
    '{"layout_name":"layout","version":"1.0.0","type":"layout","0":{"field_name":"section","field_type":"section","font_size":32.0}}';
final sectionLayout = ReportLayout(
  name: 'layout',
  fields: [SectionFieldOptions(title: 'section')],
);

const String subsectionLayoutJSON =
    '{"layout_name":"layout","version":"1.0.0","type":"layout","0":{"field_name":"section","field_type":"section","font_size":20.0}}';
final subsectionLayout = ReportLayout(
  name: 'layout',
  fields: [
    SectionFieldOptions(
      title: 'section',
      fontSize: SectionFieldOptions.subsectionSize,
    )
  ],
);

const String dateLayoutJSON =
    '{"layout_name":"layout","version":"1.0.0","type":"layout","0":{"field_name":"date","field_type":"date_field","mode":"date"}}';
final dateLayout = ReportLayout(
  name: 'layout',
  fields: [
    DateFieldOptions(
      title: 'date',
      mode: DateFieldFormats.dateModeID,
    )
  ],
);

const String dateRangeLayoutJSON =
    '{"layout_name":"layout","version":"1.0.0","type":"layout","0":{"field_name":"daterange","field_type":"date_range_field","statistics_include":true,"mode":"date_and_time","show_total":true}}';
final dateRangeLayout = ReportLayout(
  name: 'layout',
  fields: [
    DateRangeFieldOptions(
      title: 'daterange',
      mode: DateFieldFormats.dateTimeModeID,
    )
  ],
);

// -----------------------------------------------------------------------------
// - Sample Reports
// -----------------------------------------------------------------------------
const String simpleReportJSON =
    '{"report_title":"report","version":"1.0.0","type":"report","layout":"layout","0":{"field_name":"field","field_type":"text_field","statistics_include":false,"lines":1,"numeric":false,"data":"value"}}';
final simpleReport = Report(
    title: 'report',
    layout: simpleLayout,
    data: [TextFieldData(data: 'value')]);

const String dateReportJSON =
    '{"report_title":"report","version":"1.0.0","type":"report","layout":"layout","0":{"field_name":"date","field_type":"date_field","mode":"date","data":"2021-07-20 00:28:23.288288"}}';
final dateReport = Report(
    title: 'report',
    layout: dateLayout,
    data: [DateFieldData(data: DateTime.parse('2021-07-20 00:28:23.288288'))]);

const String dateRangeReportJSON =
    '{"report_title":"report","version":"1.0.0","type":"report","layout":"layout","0":{"field_name":"daterange","field_type":"date_range_field","statistics_include":true,"mode":"date_and_time","show_total":true,"data":{"start":"2021-07-25 19:21:27.038217","end":"2021-07-25 19:21:27.038219"}}}';
final dateRangeReport = Report(title: 'report', layout: dateRangeLayout, data: [
  DateRangeFieldData(
      start: DateTime.parse('2021-07-25 19:21:27.038217'),
      end: DateTime.parse('2021-07-25 19:21:27.038219'))
]);

// -----------------------------------------------------------------------------
// - Tests
// -----------------------------------------------------------------------------
void main() {
  // Set mock data for PackageInfo
  PackageInfo.setMockInitialValues(
    appName: 'Reports',
    packageName: 'com.example.reports',
    version: '1.0.0',
    buildNumber: '',
    buildSignature: '',
  );

  group('layout tests', () {
    test('encode layout', () async {
      final layout = ReportLayout(
        name: 'layout',
        fields: [TextFieldOptions(title: 'field', lines: 1, numeric: false)],
      );
      expect(await layout.toJSON(), simpleLayoutJSON);
    });
    test('roundtrip layout', () async {
      expect(await ReportLayout.fromJSON(simpleLayoutJSON).toJSON(),
          simpleLayoutJSON);
    });
    test('section layout', () async {
      expect(await sectionLayout.toJSON(), sectionLayoutJSON);
    });
    test('roundtrip section layout', () async {
      expect(await ReportLayout.fromJSON(sectionLayoutJSON).toJSON(),
          sectionLayoutJSON);
    });
    test('subsection layout', () async {
      expect(await subsectionLayout.toJSON(), subsectionLayoutJSON);
    });
    test('roundtrip subsection layout', () async {
      expect(await ReportLayout.fromJSON(subsectionLayoutJSON).toJSON(),
          subsectionLayoutJSON);
    });
    test('date field layout', () async {
      expect(await dateLayout.toJSON(), dateLayoutJSON);
    });
    test('roundtrip date field layout', () async {
      expect(
          await ReportLayout.fromJSON(dateLayoutJSON).toJSON(), dateLayoutJSON);
    });
    test('date range field layout', () async {
      expect(await dateRangeLayout.toJSON(), dateRangeLayoutJSON);
    });
    test('roudntrip date range field layout', () async {
      expect(await ReportLayout.fromJSON(dateRangeLayoutJSON).toJSON(),
          dateRangeLayoutJSON);
    });
  });

  group('report tests', () {
    test('encode report', () async {
      expect(await simpleReport.toJSON(), simpleReportJSON);
    });
    test('roundtrip report', () async {
      expect(
          await Report.fromJSON(simpleReportJSON).toJSON(), simpleReportJSON);
    });
    test('date report', () async {
      expect(await dateReport.toJSON(), dateReportJSON);
    });
    test('roundtrip date', () async {
      expect(await Report.fromJSON(dateReportJSON).toJSON(), dateReportJSON);
    });
    test('date range report', () async {
      expect(await dateRangeReport.toJSON(), dateRangeReportJSON);
    });
    test('roundtrip date range', () async {
      expect(await Report.fromJSON(dateRangeReportJSON).toJSON(),
          dateRangeReportJSON);
    });
  });
}
