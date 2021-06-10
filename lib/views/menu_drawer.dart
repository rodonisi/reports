import 'package:flutter/material.dart';
import 'package:reports/views/layouts_list.dart';
import 'report_list.dart';
import 'form_builder.dart';
import 'package:reports/views/layouts_list.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                Positioned(
                    bottom: 12.0,
                    left: 16.0,
                    child: Text("Menu",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          ListTile(
            title: Text('Reports'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, ReportList.routeName),
          ),
          ListTile(
            title: Text('Layouts'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, Layouts.routeName),
          ),
        ],
      ),
    );
  }
}
