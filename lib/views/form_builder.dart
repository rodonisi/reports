// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/form_card.dart';
import 'package:reports/widgets/loading_indicator.dart';
import 'package:reports/widgets/save_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reports/extensions/preferences_model_extensions.dart';

// -----------------------------------------------------------------------------
// - FormBuilder Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a form builder.
class FormBuilder extends StatefulWidget {
  final String path;
  FormBuilder({Key? key, this.path = ''}) : super(key: key);

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  late ReportLayout _layout;
  bool _loaded = false;
  bool _isNew = false;

  void _addField(FieldOptions options) {
    setState(() => _layout.fields.add(options));
  }

  void _removeField(int i) {
    setState(() {
      _layout.fields.removeAt(i);
    });
  }

  void _saveCallback() async {
    // Don't save if the layout is empty.
    if (_layout.fields.length == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('builder.empty').tr(),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the encoded layout.
    final layoutString = await _layout.toJSON();
    var destPath = joinAndSetExtension(
        context.read<PreferencesModel>().layoutsPath, _layout.name,
        extension: ReportsExtensions.layout);

    // Write the layout to file.
    final didWrite = await writeToFile(layoutString, destPath,
        checkExisting: destPath != widget.path, renameFrom: widget.path);
    if (!didWrite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('utility.file_exists').tr(args: [_layout.name]),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
  }

  @override
  void initState() {
    // Read layout from file
    final futureLayout = File(widget.path).readAsString();

    // Add completition callback for when the file has been read.
    futureLayout.then((value) {
      setState(() {
        _layout = ReportLayout.fromJSON(value);
        _loaded = true;
        _isNew = false;
      });
    }).catchError((error, stackTrace) async {
      final defaultName = context.read<PreferencesModel>().defaultLayoutName;
      setState(() {
        _layout = ReportLayout(
          name: defaultName,
          fields: [],
        );
        _loaded = true;
        _isNew = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // If the layout is not yet available just return a progress indicator.
    if (!_loaded) return const LoadingIndicator();

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
              ['$layoutsDir/${_layout.name}.json'],
            );
          },
        ),
      );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: ControlledTextField(
          decoration: InputDecoration(border: InputBorder.none),
          style: Theme.of(context).primaryTextTheme.headline6,
          hasClearButton: true,
          maxLines: 1,
          initialValue: _layout.name,
          onChanged: (value) => _layout.name = value,
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
        itemCount: _layout.fields.length,
        itemBuilder: (context, i) {
          return FormCard(
            key: ValueKey('LayoutItem$i'),
            options: _layout.fields[i],
            onDelete: () => _removeField(i),
          );
        },
        onReorder: (oldPos, newPos) {
          final item = _layout.fields.removeAt(oldPos);
          // We need to decrease the new index if it was previosuly in a lower
          // earlier position, because we already deleted the entry.
          if (newPos > oldPos) newPos--;
          if (newPos < _layout.fields.length)
            _layout.fields.insert(newPos, item);
          else
            _layout.fields.add(item);
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
    return SpeedDialChild(
      child: Icon(icon),
      label: label,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      iconTheme: theme.primaryIconTheme,
      backgroundColor: context.read<PreferencesModel>().accentColor,
      children: [
        _theemedDialChild(
          context: context,
          icon: Icons.date_range,
          label: 'builder.fields.date_range'.tr(),
          onTap: () => addFieldFunc(
            DateRangeFieldOptions(
              title: 'builder.fields.date_range'.tr(),
            ),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.calendar_today,
          label: 'builder.fields.date'.tr(),
          onTap: () => addFieldFunc(
            DateFieldOptions(title: 'builder.fields.date'.tr()),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.short_text,
          label: 'builder.fields.text'.tr(),
          onTap: () => addFieldFunc(
            TextFieldOptions(
              title: 'builder.fields.text'.tr(),
            ),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.text_fields,
          label: 'builder.fields.subsection'.tr(),
          onTap: () => addFieldFunc(
            SectionFieldOptions(
              title: 'builder.fields.subsection'.tr(),
              fontSize: SectionFieldOptions.subsectionSize,
            ),
          ),
        ),
        _theemedDialChild(
          context: context,
          icon: Icons.title,
          label: 'builder.fields.section'.tr(),
          onTap: () => addFieldFunc(
            SectionFieldOptions(
              title: 'builder.fields.section'.tr(),
            ),
          ),
        ),
      ],
    );
  }
}
