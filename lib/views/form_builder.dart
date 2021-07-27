// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:reports/widgets/save_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/dropbox_utils.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/preferences.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/form_tile.dart';

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
  static const String routeName = '/formBuilder';

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
      final defaultName =
          await Preferences.getDefaultName(DefaultNameType.layout);
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
    if (!loaded)
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );

    // Add the share action only if we're viewing an existing report.
    final List<Widget> shareAction = [];
    if (!_isNew)
      shareAction.add(
        IconButton(
          icon: Icon(Icons.adaptive.share),
          onPressed: () async {
            final layoutsDir = await getLayoutsDirectory;
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
          icon: Icon(Icons.close_rounded),
          color: Colors.red,
          onPressed: () => Navigator.pop(context),
        ),
        actions: shareAction,
      ),
      body: Stack(children: [
        ReorderableListView.builder(
          padding: EdgeInsets.all(16.0),
          shrinkWrap: true,
          itemCount: layout.fields.length,
          itemBuilder: (context, i) {
            return _FormBuilderCard(
              key: Key('layoutItem$i'),
              options: layout.fields[i],
              removeFunc: () => _removeField(i),
            );
          },
          onReorder: (oldPos, newPos) {
            final item = layout.fields.removeAt(oldPos);
            if (newPos < layout.fields.length)
              layout.fields.insert(newPos, item);
            else
              layout.fields.add(item);
          },
        ),
        SafeArea(
          bottom: true,
          top: false,
          child: Align(alignment: Alignment.bottomCenter, child: null),
        ),
      ]),
      floatingActionButton: _Dial(addFieldFunc: _addField),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: SaveButton(onPressed: _save),
      ),
    );
  }

  void _save() async {
    if (layout.fields.length == 0) {
      showDialog(
        context: context,
        builder: (context) {
          final localizations = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(localizations.layoutCannotBeEmpty),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.close),
              ),
            ],
          );
        },
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    final File layoutFile;
    // Write the report to file.
    if (_isNew) {
      var path = p.join(widget.args.path, layout.name);
      path = p.setExtension(path, '.json');
      layoutFile = File(path);
    } else {
      final file = File(widget.args.path);
      var newPath = p.join(file.parent.path, layout.name);
      newPath = p.setExtension(newPath, '.json');
      layoutFile = await file.rename(newPath);
    }
    await layoutFile.writeAsString(await layout.toJSON());

    // Backup the newly created file to dropbox if option is enabled.
    final dbEnabled = prefs.getBool(Preferences.dropboxEnabled);
    if (dbEnabled != null && dbEnabled) {
      // Backup to dropbox.
      dbBackupFile('${layout.name}.json', layoutsDirectory);
    }

    Navigator.pop(context);
  }
}

// -----------------------------------------------------------------------------
// - _Dial Widget Implementation
// -----------------------------------------------------------------------------
class _Dial extends StatelessWidget {
  const _Dial({Key? key, required this.addFieldFunc}) : super(key: key);
  final Function(FieldOptions) addFieldFunc;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      activeLabel: Text('close'),
      children: [
        SpeedDialChild(
          child: Icon(Icons.calendar_today),
          label: localization.dateRange,
          onTap: () => addFieldFunc(
            DateRangeFieldOptions(
              title: localization.dateRange,
            ),
          ),
        ),
        SpeedDialChild(
          child: Icon(Icons.calendar_today),
          label: localization.date,
          onTap: () => addFieldFunc(
            DateFieldOptions(title: localization.date),
          ),
        ),
        SpeedDialChild(
          child: Icon(Icons.list),
          label: localization.textFieldName,
          onTap: () => addFieldFunc(
            TextFieldOptions(
              title: localization.text,
            ),
          ),
        ),
        SpeedDialChild(
          child: Icon(Icons.list),
          label: localization.subsection,
          onTap: () => addFieldFunc(
            SectionFieldOptions(
              title: localization.subsection,
              fontSize: SectionFieldOptions.subsectionSize,
            ),
          ),
        ),
        SpeedDialChild(
          child: Icon(Icons.list),
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

// -----------------------------------------------------------------------------
// - _FormBuilderCard Widget Implementation
// -----------------------------------------------------------------------------
class _FormBuilderCard extends StatefulWidget {
  const _FormBuilderCard({
    Key? key,
    required this.options,
    required this.removeFunc,
  }) : super(key: key);
  final FieldOptions options;
  final Function() removeFunc;

  @override
  __FormBuilderCardState createState() => __FormBuilderCardState();
}

class __FormBuilderCardState extends State<_FormBuilderCard>
    with TickerProviderStateMixin {
  final _animationDuration = 150;
  bool isOpts = true;

  @override
  Widget build(BuildContext context) {
    if (widget.options is SectionFieldOptions)
      return Row(
        children: [
          Expanded(
            child: FormTileContent(options: widget.options),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () => widget.removeFunc(),
          ),
        ],
      );

    return GestureDetector(
      onTap: () => setState(() => isOpts = !isOpts),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSize(
                  duration: Duration(milliseconds: _animationDuration),
                  reverseDuration: Duration(milliseconds: _animationDuration),
                  vsync: this,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: _animationDuration),
                    reverseDuration: Duration(milliseconds: 0),
                    child: isOpts
                        ? FormTileContent(
                            options: widget.options,
                            enabled: false,
                          )
                        : FormTileOptions(
                            options: widget.options,
                          ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_forever),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () => widget.removeFunc(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
