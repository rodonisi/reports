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

class Layouts extends StatelessWidget {
  const Layouts({Key key}) : super(key: key);

  static const String routeName = '/layouts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Layouts'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(
                  context, FormBuilder.routeName,
                  arguments: FormBuilderArgs(name: 'test', fields: []))),
        ],
      ),
      drawer: MenuDrawer(),
      body: _LayoutsList(),
    );
  }
}

class _LayoutsList extends StatelessWidget {
  const _LayoutsList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _layouts = context.watch<LayoutsModel>();
    return ListView.builder(
      itemCount: _layouts.layouts.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(_layouts.layouts[index].name),
        onTap: () => Navigator.pushNamed(
          context,
          FormBuilder.routeName,
          arguments: FormBuilderArgs(
              name: _layouts.layouts[index].name,
              fields: _layouts.layouts[index].fields,
              index: index),
        ),
      ),
    );
  }
}
