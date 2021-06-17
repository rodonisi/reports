// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/theme.dart';
import 'package:reports/common/routes.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/models/reports.dart';

void main() {
  // Only allow portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Run app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LayoutsModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReportsModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Reports',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/reports',
        routes: routes,
      ),
    );
  }
}
