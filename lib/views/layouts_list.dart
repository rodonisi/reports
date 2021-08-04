// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/widgets/directory_viewer.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------

/// Displays all the layouts stored in the app in a list.
class Layouts extends StatefulWidget {
  static const String routeName = '/layouts';
  static const ValueKey valueKey = ValueKey('Layouts');

  Layouts({Key? key}) : super(key: key);

  @override
  _LayoutsState createState() => _LayoutsState();
}

class _LayoutsState extends State<Layouts> {
  void _fileActionCallback(File item) {
    showCupertinoModalBottomSheet(
      context: context,
      bounce: true,
      closeProgressThreshold: 0.4,
      builder: (context) {
        final args = FormBuilderArgs(
          path: item.path,
        );
        return FormBuilder(args: args);
      },
    ).then((value) => setState(() {}));
  }

  void _fabCallback() {
    showCupertinoModalBottomSheet(
      context: context,
      bounce: true,
      closeProgressThreshold: 0.4,
      builder: (context) {
        final args = FormBuilderArgs(path: '');
        return FormBuilder(args: args);
      },
    ).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferencesModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.layoutsTitle),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _fabCallback,
      ),
      body: DirectoryViewer(
        fileIcon: ReportsIcons.layout,
        fileAction: _fileActionCallback,
        directoryAction: (directory) {},
        directoryPath: prefs.layoutsPath,
      ),
    );
  }
}
