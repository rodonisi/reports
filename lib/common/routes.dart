// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/widgets.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/views/dropbox_chooser.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/settings.dart';

/// Contains the route of each view of the app.
final routes = {
  Reports.routeName: (context) => Reports(
        path: (ModalRoute.of(context)!.settings.arguments as String?) ?? '',
      ),
  Layouts.routeName: (context) => Layouts(),
  FormBuilder.routeName: (context) => FormBuilder(
        args: ModalRoute.of(context)!.settings.arguments as FormBuilderArgs,
      ),
  ReportViewer.routeName: (context) => ReportViewer(
        args: ModalRoute.of(context)!.settings.arguments as ReportViewerArgs,
      ),
  Settings.routeName: (context) => Settings(),
  DropboxChooser.routeName: (context) => DropboxChooser(
      args: ModalRoute.of(context)!.settings.arguments as DropboxChooserArgs),
};
