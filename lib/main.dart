// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:dropbox_client/dropbox_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  // Initialize Dropbox.
  Dropbox.init('Reports_test', 'upxehk1wmyf3a71', 'vo0cqtao0zl56oh');

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
      child: GestureDetector(
        onTap: () {
          // Get current focus.
          final currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus)
            currentFocus.focusedChild!.unfocus();
        },
        child: MaterialApp(
          title: 'Reports',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/reports',
          routes: routes,
        ),
      ),
    );
  }
}
