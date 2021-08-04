// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/common/io.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/widgets/directory_viewer.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------

/// Displays all the layouts stored in the app in a list.
class Layouts extends StatefulWidget {
  static const String routeName = '/layouts';
  static const ValueKey valueKey = ValueKey('Layouts');

  Layouts({Key? key}) : super(key: key);

  @override
  _LayoutsState createState() => _LayoutsState();
}

class _LayoutsState extends State<Layouts> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getLayoutsDirectory,
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(snapshot.error!.toString()),
          );

        Widget body;
        if (snapshot.hasData)
          body = DirectoryViewer(
            fileIcon: ReportsIcons.layout,
            fileAction: (item) => showCupertinoModalBottomSheet(
              context: context,
              bounce: true,
              closeProgressThreshold: 0.4,
              builder: (context) {
                final args = FormBuilderArgs(
                  path: item.path,
                );
                return FormBuilder(args: args);
              },
            ).then((value) => setState(() {})),
            directoryAction: (directory) {},
            directoryPath: snapshot.data!,
          );
        else
          body = Center(
            child: CircularProgressIndicator.adaptive(),
          );

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.layoutsTitle),
          ),
          floatingActionButton: snapshot.hasData
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () => showCupertinoModalBottomSheet(
                    context: context,
                    bounce: true,
                    closeProgressThreshold: 0.4,
                    builder: (context) {
                      final args = FormBuilderArgs(path: snapshot.data!);
                      return FormBuilder(args: args);
                    },
                  ).then((value) => setState(() {})),
                )
              : null,
          body: body,
        );
      },
    );
  }
}
