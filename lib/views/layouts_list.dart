import 'package:flutter/material.dart';
// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/models/layouts.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/menu_drawer.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------
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
                fields: [],
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
    var layouts = context.watch<LayoutsModel>();
    return ListView.builder(
      itemCount: layouts.layouts.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(layouts.layouts[index].name),
        onTap: () => Navigator.pushNamed(
          context,
          FormBuilder.routeName,
          arguments: FormBuilderArgs(
              name: layouts.layouts[index].name,
              fields: layouts.layouts[index].fields,
              index: index),
        ),
      ),
    );
  }
}
