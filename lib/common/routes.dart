// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/layouts_list.dart';

final routes = {
  Reports.routeName: (context) => Reports(),
  Layouts.routeName: (context) => Layouts(),
  FormBuilder.routeName: (context) => FormBuilder(),
  ReportViewer.routeName: (context) => ReportViewer(),
};
