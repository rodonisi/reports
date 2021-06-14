// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/logger.dart';
import 'package:reports/views/layouts_list.dart';
import 'package:reports/views/report_list.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
            ListTile(
              title: Text('Settings'),
              onTap: () => logger.d('Settings view'),
            ),
          ],
        ),
      ),
    );
  }
}
