// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/report_list.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

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
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Reports'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, Reports.routeName),
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
