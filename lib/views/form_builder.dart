// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/logger.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/widgets/app_bar_text_field.dart';
import 'package:reports/widgets/form_tile.dart';

// -----------------------------------------------------------------------------
// - FormBuilderArgs Class Implementation
// -----------------------------------------------------------------------------

/// Arguments class for the form builder.
class FormBuilderArgs {
  FormBuilderArgs({required this.layout, this.index});

  final ReportLayout layout;
  final int? index;
}

// -----------------------------------------------------------------------------
// - FormBuilder Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a form builder.
class FormBuilder extends StatefulWidget {
  FormBuilder({Key? key}) : super(key: key);
  static const String routeName = '/formBuilder';

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  late ReportLayout _layout;

  void _addField(FieldOptions options) {
    setState(() => _layout.fields.add(options));
  }

  void _removeField(int i) {
    setState(() {
      _layout.fields.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Controller for the layout name text field.
    final nameController = TextEditingController.fromValue(
      TextEditingValue(
        text: _layout.name,
      ),
    );

    // Get the arguments passed through the navigator.
    final _args = ModalRoute.of(context)!.settings.arguments as FormBuilderArgs;

    // Extract arguments.
    _layout = _args.layout;
    final index = _args.index;
    final isNew = index == null;

    // Add the share action only if we're viewing an existing report.
    final List<Widget> shareAction = [];
    if (!isNew)
      shareAction.add(
        IconButton(
          icon: Icon(Icons.adaptive.share),
          onPressed: () async {
            final layoutsDir = await getLayoutsDirectory;
            Share.shareFiles(
              ['$layoutsDir/${_layout.name}.json'],
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
        actions: shareAction,
      ),
      body: Stack(children: [
        ListView.builder(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            itemCount: _layout.fields.length,
            itemBuilder: (context, i) {
              return _FormBuilderCard(
                options: _layout.fields[i],
                removeFunc: () => _removeField(i),
              );
            }),
        SafeArea(
          bottom: true,
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _SaveButton(
              fields: _layout.fields,
              index: index,
              nameController: nameController,
            ),
          ),
        ),
      ]),
      floatingActionButton: _Dial(addFieldFunc: _addField),
    );
  }
}

// -----------------------------------------------------------------------------
// - _SaveButton Widget Implementation
// -----------------------------------------------------------------------------
class _SaveButton extends StatelessWidget {
  _SaveButton(
      {Key? key,
      required this.nameController,
      required this.fields,
      this.index})
      : super(key: key);
  final TextEditingController nameController;
  final List<FieldOptions> fields;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Save'),
      onPressed: () async {
        // Get the provider.
        final layoutsProvider = context.read<LayoutsModel>();

        // Initialize a new layout object.
        final newLayout =
            ReportLayout(name: nameController.text, fields: fields);

        // Update or add the layout
        if (index != null)
          layoutsProvider.update(index!, newLayout);
        else
          layoutsProvider.add(newLayout);

        // Write the layout to file.
        final file = await writeFile(
            '$layoutsDirectory/${newLayout.name}', newLayout.toJSON());

        logger.d('written file: ${file.path}');
        Navigator.pop(context);
      },
    );
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
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      activeLabel: Text('close'),
      children: [
        SpeedDialChild(
          child: Icon(Icons.list),
          label: 'Text field',
          onTap: () => addFieldFunc(TextFieldOptions()),
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
