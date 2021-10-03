// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/directory_viewer.dart';
import 'package:reports/widgets/sidebar_layout.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - LayoutsList Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the LayoutsList widget wrapped in a navigator.
class LayoutsList extends StatelessWidget {
  static const ValueKey valueKey = ValueKey('LayoutsList');

  const LayoutsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WrapNavigator(
      child: MaterialPage(
        key: _Body.valueKey,
        child: _Body(),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _Body Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the layouts directory list.
class _Body extends StatefulWidget {
  static const ValueKey valueKey = ValueKey('LayoutsListBody');

  _Body({Key? key}) : super(key: key);

  @override
  _LayoutsListState createState() => _LayoutsListState();
}

class _LayoutsListState extends State<_Body> {
  late bool _showDrawer;

  void _fileActionCallback(File item) {
    showCupertinoModalBottomSheet(
      context: context,
      bounce: true,
      closeProgressThreshold: DrawingConstants.safeSheetCloseTreshold,
      builder: (context) {
        return FormBuilder(path: item.path);
      },
    ).then((value) => setState(() {}));
  }

  void _fabCallback() {
    showCupertinoModalBottomSheet(
      context: context,
      bounce: true,
      closeProgressThreshold: DrawingConstants.safeSheetCloseTreshold,
      builder: (context) {
        return FormBuilder();
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
        title: Text('keywords.capitalized.layouts').tr(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: prefs.accentColor,
        foregroundColor: Theme.of(context).primaryIconTheme.color,
        child: const Icon(Icons.add),
        onPressed: _fabCallback,
      ),
      drawer: _showDrawer ? const Drawer(child: const MenuDrawer()) : null,
      body: DirectoryViewer(
        fileAction: _fileActionCallback,
        directoryAction: (directory) {},
        directoryPath: prefs.layoutsPath,
      ),
    );
  }
}
