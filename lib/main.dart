// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/report_viewer.dart';
import 'package:reports/views/report_list.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/common/theme.dart';
import 'package:reports/views/layouts_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LayoutsModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Reports',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/reports',
        routes: {
          ReportList.routeName: (context) => ReportList(),
          Layouts.routeName: (context) => Layouts(),
          FormBuilder.routeName: (context) => FormBuilder(),
        },
      ),
    );
  }
}
