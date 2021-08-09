// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/directory_viewer.dart';
import 'package:reports/widgets/sidebar_layout.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the LayoutsList widget wrapped in a navigator.
class Layouts extends StatelessWidget {
  static const String routeName = '/layouts';
  static const ValueKey valueKey = ValueKey('Layouts');

  const Layouts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WrapNavigator(
      child: MaterialPage(
        key: LayoutsList.valueKey,
        child: LayoutsList(),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - LayoutsList Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the layouts directory list.
class LayoutsList extends StatefulWidget {
  static const String routeName = '/layouts';
  static const ValueKey valueKey = ValueKey('LayoutsList');

  LayoutsList({Key? key}) : super(key: key);

  @override
  _LayoutsListState createState() => _LayoutsListState();
}

class _LayoutsListState extends State<LayoutsList> {
  late bool _showDrawer;

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
  void initState() {
    super.initState();
    // Only show the drawer if in narrow layout.
    _showDrawer =
        context.findAncestorWidgetOfExactType<SideBarLayout>() == null;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferencesModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.layoutsTitle),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: prefs.accentColor,
        child: Icon(Icons.add),
        onPressed: _fabCallback,
      ),
      drawer: _showDrawer ? Drawer(child: MenuDrawer()) : null,
      body: DirectoryViewer(
        fileIcon: ReportsIcons.layout,
        fileAction: _fileActionCallback,
        directoryAction: (directory) {},
        directoryPath: prefs.layoutsPath,
      ),
    );
  }
}
