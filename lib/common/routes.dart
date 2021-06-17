// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/widgets.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/layouts_list.dart';

/// Contains the route of each view of the app.
final routes = {
  Reports.routeName: (context) => Reports(),
  Layouts.routeName: (context) => Layouts(),
  FormBuilder.routeName: (context) => FormBuilder(),
  ReportViewer.routeName: (context) => ReportViewer(
        args: ModalRoute.of(context)!.settings.arguments as ReportViewerArgs,
      ),
};
