import 'package:flutter/material.dart';

Widget wrapWidgetMaterial({required Widget widget, ThemeData? theme}) {
  return MaterialApp(
    home: widget,
    theme: theme,
  );
}

Widget wrapWidgetScaffold({required Widget widget, ThemeData? theme}) {
  return wrapWidgetMaterial(
    widget: Scaffold(
      body: widget,
    ),
    theme: theme,
  );
}
