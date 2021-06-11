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

// -----------------------------------------------------------------------------
// - FormBuilderArgs Class Implementation
// -----------------------------------------------------------------------------
class FormBuilderArgs {
  FormBuilderArgs({required this.name, required this.fields, this.index});

  final String name;
  final List<FieldOptions> fields;
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
  List<FieldOptions> _fields = [];

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
              _fields.add(FieldOptions(
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
      _fields.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _args = ModalRoute.of(context)!.settings.arguments as FormBuilderArgs;
    _fields = _args.fields;
    final nameController = TextEditingController.fromValue(
      TextEditingValue(
        text: _args.name,
      ),
    );
    final index = _args.index;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: _AppBarTextField(
          controller: nameController,
        ),
      ),
      body: Stack(children: [
        ListView.builder(
            padding: EdgeInsets.all(16.0),
            shrinkWrap: true,
            itemCount: _fields.length,
            itemBuilder: (context, i) {
              return _FormCard(
                options: _fields[i],
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
              fields: _fields,
              index: index,
              name: nameController.text,
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
  _SaveButton({Key? key, this.name, this.fields, this.index}) : super(key: key);
  final name;
  final fields;
  final index;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Save'),
      onPressed: () {
        var layout = context.read<LayoutsModel>();
        final newLayout = ReportLayout(name: name, fields: fields);
        if (index != null)
          layout.update(index, newLayout);
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
// - _AppBarTextField Widget Implementation
// -----------------------------------------------------------------------------
class _AppBarTextField extends StatelessWidget {
  const _AppBarTextField({Key? key, required this.controller})
      : super(key: key);
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
      ),
      // textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
