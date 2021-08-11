// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/widgets/controlled_text_field.dart';

// -----------------------------------------------------------------------------
// - FormCard Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a form card wrt to the given options. The displayed field type is
/// determined by the type of the FieldOptions object.
/// NOTE: If no data is provided then the returned FormCard is in the form
/// builder state, i.e. it displays a delete button and a onDelete callback has
/// to be provided. Futhermore the fields are disabled and tapping the cards
/// reveal the field options. If data is passed then the returned card is in the
/// viewer state, i.e. the fields are enabled and the remove buttons hidden.
class FormCard extends StatefulWidget {
  const FormCard({Key? key, required this.options, this.data, this.onDelete})
      : super(key: key);

  final FieldOptions options;
  final FieldData? data;
  final void Function()? onDelete;

  @override
  _FormCardState createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  final ValueNotifier<bool> _showOptions = ValueNotifier(false);
  Widget _getCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.data == null
            ? _FormBuilderCardContent(
                options: widget.options,
                onDelete: widget.onDelete!,
              )
            : _FormCardContent(
                options: widget.options,
                data: widget.data,
              ),
      ),
    );
  }

  Widget _getFormCard() {
    return ValueListenableBuilder<bool>(
        valueListenable: _showOptions,
        builder: (context, value, _) {
          return Provider<bool>.value(
            value: value,
            child: GestureDetector(
              onTap: () => _showOptions.value = !_showOptions.value,
              child: _getCard(),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options is SectionFieldOptions) {
      if (widget.data == null)
        return Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: _DeleteButtonRow(
            child: _FormCardContent(options: widget.options),
            onDelete: widget.onDelete!,
          ),
        );
      else
        return _FormCardContent(
          options: widget.options,
          enabled: false,
        );
    }

    return widget.data == null ? _getFormCard() : _getCard();
  }
}

// -----------------------------------------------------------------------------
// - Content widgets
// -----------------------------------------------------------------------------

class _FormBuilderCardContent extends StatefulWidget {
  const _FormBuilderCardContent({
    Key? key,
    required this.options,
    required this.onDelete,
  }) : super(key: key);
  final FieldOptions options;
  final Function() onDelete;

  @override
  __FormBuilderCardContentState createState() =>
      __FormBuilderCardContentState();
}

class __FormBuilderCardContentState extends State<_FormBuilderCardContent>
    with TickerProviderStateMixin {
  final _animationDuration = 150;

  @override
  Widget build(BuildContext context) {
    return _DeleteButtonRow(
      child: AnimatedSize(
        duration: Duration(milliseconds: _animationDuration),
        reverseDuration: Duration(milliseconds: _animationDuration),
        vsync: this,
        child: context.watch<bool>()
            ? _FormCardOptions(
                options: widget.options,
              )
            : _FormCardContent(
                options: widget.options,
                enabled: false,
              ),
      ),
      onDelete: widget.onDelete,
    );
  }
}

class _DeleteButtonRow extends StatelessWidget {
  const _DeleteButtonRow(
      {Key? key, required this.child, required this.onDelete})
      : super(key: key);

  final Widget child;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: child),
        IconButton(
          icon: const Icon(Icons.delete_forever),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// - Card content widgets
// -----------------------------------------------------------------------------

// Creates the card content based on the options.
class _FormCardContent extends StatelessWidget {
  const _FormCardContent({
    Key? key,
    required this.options,
    this.enabled = true,
    this.data,
  }) : super(key: key);

  final FieldOptions options;
  final FieldData? data;
  final bool enabled;

  Widget _getField(BuildContext context) {
    final bool _enabled =
        data != null && !context.read<PreferencesModel>().readerMode;
    switch (options.fieldType) {
      case FieldTypes.textField:
        return _TextFieldContent(
          options: options as TextFieldOptions,
          data: data as TextFieldData? ?? TextFieldData(data: ''),
          enabled: _enabled,
        );
      case FieldTypes.date:
        return _DateFieldContent(
          options: options as DateFieldOptions,
          data: data as DateFieldData? ?? DateFieldData(data: DateTime.now()),
          enabled: _enabled,
        );
      case FieldTypes.dateRange:
        return _DateRangeFieldContent(
            options: options as DateRangeFieldOptions,
            data: data as DateRangeFieldData? ?? DateRangeFieldData.empty(),
            enabled: _enabled);
      default:
        throw ArgumentError.value(options.fieldType, 'unsupported field type');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (options is SectionFieldOptions)
      return _SectionFieldContent(
        options: options as SectionFieldOptions,
        enabled: enabled,
      );
    ;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          options.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _getField(context),
      ],
    );
  }
}

class _SectionFieldContent extends StatelessWidget {
  const _SectionFieldContent(
      {Key? key, required this.options, required this.enabled})
      : super(key: key);
  final SectionFieldOptions options;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ControlledTextField(
      key: ObjectKey(options),
      enabled: enabled,
      initialValue: options.title,
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      style: TextStyle(
        fontSize: options.fontSize,
        fontWeight: FontWeight.bold,
      ),
      onChanged: (val) => options.title = val,
    );
  }
}

class _TextFieldContent extends StatelessWidget {
  const _TextFieldContent(
      {Key? key,
      required this.options,
      required this.data,
      required this.enabled})
      : super(key: key);

  final TextFieldOptions options;
  final TextFieldData data;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ControlledTextField(
      key: ObjectKey(options),
      onChanged: (value) => data.data = value,
      enabled: enabled,
      maxLines: options.lines,
      initialValue: data.data,
      keyboardType: options.numeric ? TextInputType.number : TextInputType.text,
    );
  }
}

DateTime _setMidnight(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

class _DateFieldContent extends StatefulWidget {
  const _DateFieldContent({
    Key? key,
    required this.options,
    required this.data,
    required this.enabled,
  }) : super(key: key);

  final DateFieldOptions options;
  final DateFieldData data;
  final bool enabled;

  @override
  __DateFieldContentState createState() => __DateFieldContentState();
}

class __DateFieldContentState extends State<_DateFieldContent> {
  void _onDateSelectedCallback(DateTime value) {
    final DateTime adjustedValue;

    // Ensure date is on midnight if in date mode.
    if (widget.options.mode == DateFieldFormats.dateModeID)
      adjustedValue = _setMidnight(value);
    else
      adjustedValue = value;

    setState(() => widget.data.data = adjustedValue);
  }

  @override
  Widget build(BuildContext context) {
    return DateTimeField(
      key: ObjectKey(widget.options),
      onDateSelected: _onDateSelectedCallback,
      selectedDate: widget.data.data,
      enabled: widget.enabled,
      dateFormat: widget.options.getFormat,
      mode: DateFieldFormats.getDateTimeFieldPickerMode(widget.options.mode),
    );
  }
}

class _DateRangeFieldContent extends StatefulWidget {
  const _DateRangeFieldContent({
    Key? key,
    required this.options,
    required this.data,
    required this.enabled,
  }) : super(key: key);

  final DateRangeFieldOptions options;
  final DateRangeFieldData data;
  final bool enabled;

  @override
  __DateRangeFieldContentState createState() => __DateRangeFieldContentState();
}

class __DateRangeFieldContentState extends State<_DateRangeFieldContent> {
  DateTime _adjustDate(DateTime start, DateTime end) {
    final day = const Duration(days: 1);
    // Remove a day to end if the duration difference surpasses one day.
    if (end.difference(start).compareTo(day) > 0) return end.subtract(day);
    // Add a day to end if the duration difference would be negative.
    if (start.isAfter(end)) return end.add(day);

    // Otherwise return the end date as is.
    return end;
  }

  void _onStartSelectedCallback(DateTime value) {
    final DateTime adjustedValue;
    // Ensure date is on midnight if in date mode.
    if (widget.options.mode == DateFieldFormats.dateModeID)
      adjustedValue = _setMidnight(value);
    else
      adjustedValue = value;
    setState(() {
      widget.data.start = adjustedValue;

      // Adjust the end date if in time mode.
      if (widget.options.mode == DateFieldFormats.timeModeID) {
        widget.data.end = _adjustDate(value, widget.data.end);
      }
    });
  }

  void _onEndSelectedCallback(DateTime value) {
    final DateTime adjustedValue;

    if (widget.options.mode == DateFieldFormats.timeModeID)
      // Adjust the end date if in time mode.
      adjustedValue = _adjustDate(widget.data.start, value);
    else if (widget.options.mode == DateFieldFormats.dateModeID)
      // Ensure date is on midnight if in date mode.
      adjustedValue = _setMidnight(value);
    else
      adjustedValue = value;
    setState(() {
      widget.data.end = adjustedValue;
    });
  }

  String _getDifference() {
    final duration = widget.data.end.difference(widget.data.start);
    var total = '';
    if (duration.inDays > 0) {
      total = '${duration.inDays} days, ';
    }

    if (duration.inHours > 0) {
      total += '${duration.inHours.remainder(24)} hours, ';
    }

    total += '${duration.inMinutes.remainder(60)} minutes';

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          key: ObjectKey(widget.options),
          children: [
            Expanded(
              child: DateTimeField(
                onDateSelected: _onStartSelectedCallback,
                selectedDate: widget.data.start,
                enabled: widget.enabled,
                dateFormat: widget.options.getFormat,
                mode: DateFieldFormats.getDateTimeFieldPickerMode(
                    widget.options.mode),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('-'),
            ),
            Expanded(
              child: DateTimeField(
                onDateSelected: _onEndSelectedCallback,
                selectedDate: widget.data.end,
                enabled: widget.enabled,
                dateFormat: widget.options.getFormat,
                mode: DateFieldFormats.getDateTimeFieldPickerMode(
                    widget.options.mode),
              ),
            ),
          ],
        ),
        if (widget.options.showTotal)
          SizedBox(
            height: 8.0,
          ),
        if (widget.options.showTotal)
          Row(
            children: [
              Text(
                'Summary: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_getDifference()),
            ],
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// - Field Options
// -----------------------------------------------------------------------------

// Creates the options for the form card of the given type.
class _FormCardOptions extends StatelessWidget {
  const _FormCardOptions({Key? key, required this.options}) : super(key: key);

  final FieldOptions options;

  @override
  Widget build(BuildContext context) {
    switch (options.fieldType) {
      case FieldTypes.textField:
        return _TextFieldOptions(
          options: options as TextFieldOptions,
        );
      case FieldTypes.date:
        return _DateFieldOptions(
          options: options as DateFieldOptions,
        );
      case FieldTypes.dateRange:
        return _DateRangeFieldOptions(
          options: options as DateRangeFieldOptions,
        );
      default:
        throw ArgumentError.value(options.fieldType, 'unsupported field type');
    }
  }
}

List<Widget> _getCommonOptions(
    BuildContext context, FieldOptions options, String title) {
  final localization = AppLocalizations.of(context)!;
  final opts = [
    Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    ),
    Divider(),
    Text(
      localization.title,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    ControlledTextField(
      initialValue: options.title,
      onChanged: (value) => options.title = value,
    ),
    SizedBox(
      height: 20.0,
    ),
  ];

  return opts;
}

class _TextFieldOptions extends StatelessWidget {
  _TextFieldOptions({Key? key, required this.options}) : super(key: key);

  final TextFieldOptions options;
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._getCommonOptions(
            context, options, localization.textFieldOptionsHeader),
        Text(
          localization.lines,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ControlledTextField(
          initialValue: options.lines.toString(),
          onChanged: (value) => options.lines = int.parse(value),
          keyboardType: TextInputType.number,
        ),
        _SwitchOption(
          title: localization.numericKeyboard,
          getter: options.getNumeric,
          setter: options.setNumeric,
        ),
      ],
    );
  }
}

class _DateFieldOptions extends StatelessWidget {
  _DateFieldOptions({Key? key, required this.options}) : super(key: key);

  final DateFieldOptions options;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._getCommonOptions(
            context, options, localizations.dateFieldOptionsHeader),
        Text(
          localizations.mode,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _DropdownOption<String>(
          getter: () => options.mode,
          setter: (String value) => options.mode = value,
          items: [
            DropdownMenuItem(
              child: Text(localizations.date),
              value: DateFieldFormats.dateModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.time),
              value: DateFieldFormats.timeModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.dateAndTime),
              value: DateFieldFormats.dateTimeModeID,
            )
          ],
        ),
      ],
    );
  }
}

class _DateRangeFieldOptions extends StatelessWidget {
  _DateRangeFieldOptions({Key? key, required this.options}) : super(key: key);

  final DateRangeFieldOptions options;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._getCommonOptions(
            context, options, localizations.dateFieldOptionsHeader),
        Text(
          localizations.mode,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _DropdownOption<String>(
          items: [
            DropdownMenuItem(
              child: Text(localizations.date),
              value: DateFieldFormats.dateModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.time),
              value: DateFieldFormats.timeModeID,
            ),
            DropdownMenuItem(
              child: Text(localizations.dateAndTime),
              value: DateFieldFormats.dateTimeModeID,
            )
          ],
          getter: () => options.mode,
          setter: (String value) => options.mode = value,
        ),
        _SwitchOption(
          title: 'Show summary',
          getter: () => options.showTotal,
          setter: (value) => options.showTotal = value,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// - Options Widgets
// -----------------------------------------------------------------------------

class _DropdownOption<T> extends StatefulWidget {
  _DropdownOption(
      {Key? key,
      required this.getter,
      required this.setter,
      required this.items})
      : super(key: key);

  final T Function() getter;
  final void Function(T value) setter;
  final List<DropdownMenuItem<T>> items;

  @override
  __DropdownOptionState createState() => __DropdownOptionState<T>();
}

class __DropdownOptionState<T> extends State<_DropdownOption<T>> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      isExpanded: true,
      value: widget.getter(),
      underline: Container(color: Colors.grey, height: 1.0),
      items: widget.items,
      onChanged: (value) => setState(() => widget.setter(value!)),
    );
  }
}

class _SwitchOption extends StatefulWidget {
  _SwitchOption({
    Key? key,
    required this.title,
    required this.getter,
    required this.setter,
  }) : super(key: key);

  final String title;
  final getter;
  final setter;

  @override
  __SwitchOptionState createState() => __SwitchOptionState();
}

class __SwitchOptionState extends State<_SwitchOption> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Switch.adaptive(
            value: widget.getter(),
            onChanged: (val) {
              setState(() {
                widget.setter(val);
              });
            })
      ],
    );
  }
}
