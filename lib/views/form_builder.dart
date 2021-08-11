// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reports/utilities/dropbox_utils.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/form_card.dart';
import 'package:reports/widgets/loading_indicator.dart';
import 'package:reports/widgets/save_button.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - FormBuilderArgs Class Implementation
// -----------------------------------------------------------------------------

/// Arguments class for the form builder.
class FormBuilderArgs {
  FormBuilderArgs({required this.path});

  final String path;
}

// -----------------------------------------------------------------------------
// - FormBuilder Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a form builder.
class FormBuilder extends StatefulWidget {
  final FormBuilderArgs args;
  FormBuilder({Key? key, required this.args}) : super(key: key);

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  late ReportLayout layout;
  bool loaded = false;
  bool _isNew = false;

  void _addField(FieldOptions options) {
    setState(() => layout.fields.add(options));
  }

  void _removeField(int i) {
    setState(() {
      layout.fields.removeAt(i);
    });
  }

  void _saveCallback() async {
    final localizations = AppLocalizations.of(context)!;
    if (layout.fields.length == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(localizations.layoutCannotBeEmpty),
          backgroundColor: Colors.red));
      return;
    }

    final layoutString = await layout.toJSON();
    var destPath = '';
    var fromPath = '';

    if (_isNew) {
      destPath = joinAndSetExtension(
          context.read<PreferencesModel>().layoutsPath, layout.name);
    } else {
      destPath = joinAndSetExtension(p.dirname(widget.args.path), layout.name);
      if (destPath != widget.args.path) fromPath = widget.args.path;
    }

    // Write the layout to file.
    final didWrite = await writeToFile(layoutString, destPath,
        checkExisting: destPath != widget.args.path, renameFrom: fromPath);
    if (!didWrite) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(localizations.fileExists(localizations.layout)),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Backup the newly created file to dropbox if option is enabled.
    if (context.read<PreferencesModel>().dropboxEnabled) {
      // Backup to dropbox.
      dbBackupFile(context, destPath);
    }

    Navigator.pop(context);
  }

  @override
  void initState() {
    // Read layout from file
    final futureLayout = File(widget.args.path).readAsString();

    // Add completition callback for when the file has been read.
    futureLayout.then((value) {
      setState(() {
        layout = ReportLayout.fromJSON(value);
        loaded = true;
        _isNew = false;
      });
    }).catchError((error, stackTrace) async {
      final defaultName = context.read<PreferencesModel>().defaultLayoutName;
      setState(() {
        layout = ReportLayout(
          name: defaultName,
          fields: [],
        );
        loaded = true;
        _isNew = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // If the layout is not yet available just return a progress indicator.
    if (!loaded) return const LoadingIndicator();

    // Add the share action only if we're viewing an existing report.
    final List<Widget> shareAction = [];
    if (!_isNew)
      shareAction.add(
        IconButton(
          icon: Icon(Icons.adaptive.share),
          onPressed: () {
            final layoutsDir =
                context.read<PreferencesModel>().layoutsDirectory;
            Share.shareFiles(
              ['$layoutsDir/${layout.name}.json'],
            );
          },
        ),
      );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: ControlledTextField(
          decoration: InputDecoration(border: InputBorder.none),
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          hasClearButton: true,
          maxLines: 1,
          initialValue: layout.name,
          onChanged: (value) => layout.name = value,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: Colors.red,
          onPressed: () => Navigator.pop(context),
        ),
        actions: shareAction,
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16.0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: layout.fields.length,
        itemBuilder: (context, i) {
          return FormCard(
            key: ValueKey('LayoutItem$i'),
            options: layout.fields[i],
            onDelete: () => _removeField(i),
          );
        },
        onReorder: (oldPos, newPos) {
          final item = layout.fields.removeAt(oldPos);
          // We need to decrease the new index if it was previosuly in a lower
          // earlier position, because we already deleted the entry.
          if (newPos > oldPos) newPos--;
          if (newPos < layout.fields.length)
            layout.fields.insert(newPos, item);
          else
            layout.fields.add(item);
        },
      ),
      floatingActionButton: _Dial(addFieldFunc: _addField),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: SaveButton(onPressed: _saveCallback),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - Private Widgets
// -----------------------------------------------------------------------------
class _Dial extends StatelessWidget {
  const _Dial({Key? key, required this.addFieldFunc}) : super(key: key);
  final Function(FieldOptions) addFieldFunc;

  SpeedDialChild _theemedDialChild({
    required BuildContext context,
    required IconData icon,
    required String label,
    required void Function() onTap,
  }) {
    final theme = Theme.of(context);
    return SpeedDialChild(
      child: Icon(
        icon,
        color: theme.iconTheme.color,
      ),
      backgroundColor: theme.backgroundColor,
      labelBackgroundColor: theme.backgroundColor,
      label: label,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      iconTheme: theme.iconTheme,
      backgroundColor: context.read<PreferencesModel>().accentColor,
      overlayColor: theme.primaryColor,
      children: [
        _theemedDialChild(
          context: context,
          icon: Icons.date_range,
          label: localization.dateRange,
          onTap: () => addFieldFunc(
            DateRangeFieldOptions(
              title: localization.dateRange,
            ),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.calendar_today,
          label: localization.date,
          onTap: () => addFieldFunc(
            DateFieldOptions(title: localization.date),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.short_text,
          label: localization.textFieldName,
          onTap: () => addFieldFunc(
            TextFieldOptions(
              title: localization.text,
            ),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.text_fields,
          label: localization.subsection,
          onTap: () => addFieldFunc(
            SectionFieldOptions(
              title: localization.subsection,
              fontSize: SectionFieldOptions.subsectionSize,
            ),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.title,
          label: localization.section,
          onTap: () => addFieldFunc(
            SectionFieldOptions(
              title: localization.section,
            ),
          ),
        ),
      ],
    );
  }
}
