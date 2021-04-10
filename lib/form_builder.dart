import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:date_field/date_field.dart';
import 'package:logger/logger.dart';

class FieldOptions {
  FieldOptions({this.title, this.fieldType});
  final String title;
  final int fieldType;
}

class TextFieldOptions extends FieldOptions {
  TextFieldOptions({String title, int fieldType, this.lines})
      : super(title: title, fieldType: fieldType);
  final int lines;
}

class FormBuilder extends StatefulWidget {
  FormBuilder({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  final logger = Logger(printer: PrettyPrinter(methodCount: 0));
  final _fields = <FieldOptions>[];
  Widget _getField(FieldOptions options) {
    switch (options.fieldType) {
      case 0:
        return TextField(
          enabled: false,
        );
      case 1:
        return DateTimeFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.event_note),
          ),
          mode: DateTimeFieldPickerMode.time,
          enabled: false,
        );
      case 2:
        return DateTimeFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.event_note),
          ),
          mode: DateTimeFieldPickerMode.date,
        );
      case 3:
        return DateTimeFormField(
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.event_note),
          ),
          mode: DateTimeFieldPickerMode.dateAndTime,
        );
      case 4:
        return Row(
          children: [
            Expanded(
                child: DateTimeFormField(
              mode: DateTimeFieldPickerMode.time,
            )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('-'),
            ),
            Expanded(
                child: DateTimeFormField(
              mode: DateTimeFieldPickerMode.time,
            )),
          ],
        );
      default:
        return null;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(16.0),
          shrinkWrap: true,
          itemBuilder: (context, i) {
            if (i < _fields.length) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fields[i].title),
                            _getField(_fields[i])
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          setState(() {
                            _fields.removeAt(i);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return null;
          }),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        activeLabel: Text('close'),
        children: [
          SpeedDialChild(
            child: Icon(Icons.list),
            label: 'Text field',
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context, 0),
            ),
          ),
          SpeedDialChild(
            child: Icon(Icons.list),
            label: 'Time',
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context, 1),
            ),
          ),
          SpeedDialChild(
            child: Icon(Icons.list),
            label: 'Date',
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context, 2),
            ),
          ),
          SpeedDialChild(
            child: Icon(Icons.list),
            label: 'DateTime',
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context, 3),
            ),
          ),
          SpeedDialChild(
            child: Icon(Icons.list),
            label: 'TimeRange',
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context, 4),
            ),
          ),
        ],
      ),
    );
  }
}
