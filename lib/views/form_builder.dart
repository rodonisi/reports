// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/logger.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/structures/report_structures.dart';
import 'package:reports/widgets/app_bar_text_field.dart';

// -----------------------------------------------------------------------------
// - FormBuilderArgs Class Implementation
// -----------------------------------------------------------------------------
class FormBuilderArgs {
  FormBuilderArgs({required this.layout, this.index});

  final ReportLayout layout;
  final int? index;
}

// -----------------------------------------------------------------------------
// - FormBuilder Widget Implementation
// -----------------------------------------------------------------------------
class FormBuilder extends StatefulWidget {
  FormBuilder({Key? key}) : super(key: key);
  static const String routeName = '/formBuilder';

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  late ReportLayout _layout;

  Widget _buildPopupDialog(BuildContext context, int type) {
    final textFieldController = TextEditingController();
    return new AlertDialog(
      title: const Text('Field Title'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: textFieldController,
          ),
        ],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            setState(() {
              _layout.fields.add(FieldOptions(
                title: textFieldController.text,
                fieldType: type,
              ));
              logger.v(
                  'Add new field:\n  > type: $type\n  > title ${textFieldController.text}');
            });
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _removeField(int i) {
    setState(() {
      _layout.fields.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _args = ModalRoute.of(context)!.settings.arguments as FormBuilderArgs;
    _layout = _args.layout;
    final nameController = TextEditingController.fromValue(
      TextEditingValue(
        text: _layout.name,
      ),
    );
    final index = _args.index;
    final isNew = index == null;

    final List<Widget> shareAction = [];
    if (!isNew)
      shareAction.add(
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => _ExportDialog(text: _layout.toJSON()));
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
              return _FormCard(
                options: _layout.fields[i],
                index: i,
                removeFunc: _removeField,
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
      floatingActionButton: _Dial(buildPopupDialog: _buildPopupDialog),
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
      onPressed: () {
        var layout = context.read<LayoutsModel>();
        final newLayout =
            ReportLayout(name: nameController.text, fields: fields);
        if (index != null)
          layout.update(index!, newLayout);
        else
          layout.add(newLayout);
        Navigator.pop(context);
        logger.d("Saved layout");
      },
    );
  }
}

// -----------------------------------------------------------------------------
// - _Dial Widget Implementation
// -----------------------------------------------------------------------------
class _Dial extends StatelessWidget {
  const _Dial({Key? key, this.buildPopupDialog}) : super(key: key);
  final buildPopupDialog;

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
          onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) => buildPopupDialog(context, 0),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// - _FormCard Widget Implementation
// -----------------------------------------------------------------------------
class _FormCard extends StatelessWidget {
  const _FormCard({
    Key? key,
    required this.options,
    required this.index,
    required this.removeFunc,
  }) : super(key: key);
  final FieldOptions options;
  final int index;
  final removeFunc;

  Widget _getField() {
    switch (options.fieldType) {
      case 0:
        return TextField(
          enabled: false,
        );
      default:
        throw ArgumentError.value(options.fieldType, 'unsupported field type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(options.title), _getField()],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_forever),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: () => removeFunc(index),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _ExportDialog Widget Declaration
// -----------------------------------------------------------------------------
class _ExportDialog extends StatelessWidget {
  const _ExportDialog({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('JSON Export'),
      content: SelectableText(text),
      actions: <Widget>[
        new TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Close',
              overflow: TextOverflow.ellipsis,
            )),
      ],
    );
  }
}
