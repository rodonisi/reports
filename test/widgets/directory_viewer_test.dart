import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reports/widgets/directory_viewer.dart';

import '../utilities.dart';

void main() {
  testWidgets('test zero files', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp();

      await tester.pumpWidget(wrapWidgetScaffold(
          widget: DirectoryViewer(
        fileAction: (item) {},
        directoryAction: (item) {},
        directoryPath: directory.path,
      )));

      final findListTile = find.byType(ListTile);

      // There should be no tiles when there are no files in the directory.
      expect(findListTile, findsNothing);
    });
  });
  testWidgets('test one file', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp();
      await File('${directory.path}/test.json').create();

      await tester.pumpWidget(wrapWidgetScaffold(
          widget: DirectoryViewer(
        fileAction: (item) {},
        directoryAction: (item) {},
        directoryPath: directory.path,
      )));

      final findListTile = find.byType(ListTile);
      final findTestText = find.text('test');

      // If one file is in the directory there should be exactly one tile with
      // the file name as the title
      expect(findListTile, findsOneWidget);
      expect(findTestText, findsOneWidget);
    });
  });
  testWidgets('test two files', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp();
      await File('${directory.path}/test.json').create();
      await File('${directory.path}/test2.json').create();

      await tester.pumpWidget(wrapWidgetScaffold(
          widget: DirectoryViewer(
        fileAction: (item) {},
        directoryAction: (item) {},
        directoryPath: directory.path,
      )));

      final findListTile = find.byType(ListTile);
      final findTestText = find.text('test');
      final findTest2Text = find.text('test2');

      // With two files there should be two tiles with the respective file names
      // as titles.
      expect(findListTile, findsNWidgets(2));
      expect(findTestText, findsOneWidget);
      expect(findTest2Text, findsOneWidget);
    });
  });
  testWidgets('test default layout', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp();
      await Directory('${directory.path}/dir').create();
      await File('${directory.path}/test.json').create();

      await tester.pumpWidget(wrapWidgetScaffold(
          widget: DirectoryViewer(
        fileAction: (item) {},
        directoryAction: (item) {},
        directoryPath: directory.path,
      )));

      final findListTile = find.byType(ListTile);

      // There should be exactly two tiles.
      expect(findListTile, findsNWidgets(2));

      final evaluate = findListTile.evaluate();

      // The directory tile should be the first as the list is sorted by paths.
      final dirTile = evaluate.first.widget as ListTile;
      // The text should be the directory name.
      expect((dirTile.title as Text).data, 'dir');
      // The leading widget should be a folder icon.
      expect((dirTile.leading as Icon).icon, Icons.folder);

      // The file tile comes second as it should be sorted after dir.
      final fileTile = evaluate.last.widget as ListTile;
      // The text should be the file name without extension.
      expect((fileTile.title as Text).data, 'test');
      // The leading widget should be a description icon.
      expect((fileTile.leading as Icon).icon, Icons.description);
    });
  });
  testWidgets('test custom file icon', (WidgetTester tester) async {
    final findListTile = find.byType(ListTile);
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp();
      await Directory('${directory.path}/dir').create();
      await File('${directory.path}/test.json').create();

      await tester.pumpWidget(wrapWidgetScaffold(
          widget: DirectoryViewer(
        fileIcon: Icons.ac_unit,
        fileAction: (item) {},
        directoryAction: (item) {},
        directoryPath: directory.path,
      )));

      final evaluate = findListTile.evaluate();

      // The directory tile should be the first as the list is sorted by paths.
      final dirTile = evaluate.first.widget as ListTile;
      // The folder icon should be unaffected by the custom file icon.
      expect((dirTile.leading as Icon).icon, Icons.folder);

      // The file tile comes second as it should be sorted after dir.
      final fileTile = evaluate.last.widget as ListTile;
      // The leading widget should be a ac_unit icon as the argument is defined.
      expect((fileTile.leading as Icon).icon, Icons.ac_unit);
    });
  });
  testWidgets('test actions', (WidgetTester tester) async {
    final printLog = [];
    void print(String s) => printLog.add(s);

    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp();
      await Directory('${directory.path}/dir').create();
      await File('${directory.path}/test.json').create();

      await tester.pumpWidget(wrapWidgetScaffold(
          widget: DirectoryViewer(
        fileAction: (item) => print('file'),
        directoryAction: (item) => print('dir'),
        directoryPath: directory.path,
      )));

      final findListTile = find.byType(ListTile);
      await tester.tap(findListTile.first);

      // Tapping the first tile (dir) should trigger the directory action.
      expect(printLog.first, 'dir');

      // Tapping the second tile (file) should trigger the file action.
      await tester.tap(findListTile.last);
      expect(printLog.last, 'file');
    });
  });
}
