// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
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
import 'package:reports/models/layouts.dart';
import 'package:reports/widgets/app_bar_text_field.dart';
import 'package:reports/widgets/form_tile.dart';

// -----------------------------------------------------------------------------
// - FormBuilderArgs Class Implementation
// -----------------------------------------------------------------------------

/// Arguments class for the form builder.
class FormBuilderArgs {
  FormBuilderArgs({required this.name, this.index});

  final String name;
  final int? index;
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
  final nameController = TextEditingController();

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
    final futureReport = readNamedLayout(widget.args.name);

    // Add completition callback for when the file has been read.
    futureReport.then((value) {
      setState(() {
        layout = ReportLayout.fromJSON(value);
        nameController.text = layout.name;
        loaded = true;
      });
    }).catchError((error, stackTrace) {
      setState(() {
        layout = ReportLayout(
          name: widget.args.name,
          fields: [],
        );
        nameController.text = layout.name;
        loaded = true;
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

    // Determine whether this is a new layout.
    final isNew = widget.args.index == null;

    // Add the share action only if we're viewing an existing report.
    final List<Widget> shareAction = [];
    if (!isNew)
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
        title: AppBarTextField(
          controller: nameController,
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
      bottomNavigationBar: SaveButton(onPressed: _save),
    );
  }

  void _save() async {
    final prefs = await SharedPreferences.getInstance();

    // Save the old name to determine whether it has been updated.
    final oldName = layout.name;
    layout.name = nameController.text;

    // Get the provider.
    final layoutsProvider = context.read<LayoutsModel>();

    // Update or add the layout
    if (widget.args.index != null)
      layoutsProvider.update(widget.args.index!, layout.name);
    else
      layoutsProvider.add(layout.name);

    // Write the layout to file.
    final file = renameAndWriteFile('$layoutsDirectory/$oldName',
        '$layoutsDirectory/${layout.name}', layout.toJSON());

    // Backup the newly created file to dropbox if option is enabled.
    final dbEnabled = prefs.getBool(Preferences.dropboxEnabled);
    if (dbEnabled != null && dbEnabled) {
      // Wait for the file to be written
      await file;
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
          child: Icon(Icons.list),
          label: localization.layoutTextFieldName,
          onTap: () => addFieldFunc(TextFieldOptions()),
        ),
        SpeedDialChild(
          child: Icon(Icons.list),
          label: localization.subsection,
          onTap: () => addFieldFunc(SectionFieldOptions(
            title: localization.subsection,
            fontSize: SectionFieldOptions.subsectionSize,
          )),
        ),
        SpeedDialChild(
          child: Icon(Icons.list),
          label: localization.layoutSectionFieldName,
          onTap: () => addFieldFunc(SectionFieldOptions()),
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
