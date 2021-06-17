// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/menu_drawer.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------

/// Displays all the layouts stored in the app in a list.
class Layouts extends StatelessWidget {
  const Layouts({Key? key}) : super(key: key);

  static const String routeName = '/layouts';

  @override
  Widget build(BuildContext context) {
    var _layoutsProvider = context.watch<LayoutsModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Layouts'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(
              context,
              FormBuilder.routeName,
              arguments: FormBuilderArgs(
                name: 'Layout ${_layoutsProvider.layouts.length}',
              ),
            ),
          ),
        ],
      ),
      drawer: MenuDrawer(),
      body: _LayoutsList(),
    );
  }
}

// -----------------------------------------------------------------------------
// - _LayoutList Widget Implementation
// -----------------------------------------------------------------------------
class _LayoutsList extends StatelessWidget {
  const _LayoutsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var layoutsProvider = context.watch<LayoutsModel>();
    return ListView.separated(
      itemCount: layoutsProvider.layouts.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(layoutsProvider.layouts[index]),
        leading: Icon(ReportsIcons.layout_detailed),
        onTap: () => Navigator.pushNamed(
          context,
          FormBuilder.routeName,
          arguments: FormBuilderArgs(
            name: layoutsProvider.layouts[index],
            index: index,
          ),
        ),
      ),
      separatorBuilder: (context, index) => Divider(),
    );
  }
}
