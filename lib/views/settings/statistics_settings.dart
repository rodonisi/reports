// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/common/rule_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/utilities/print_utils.dart';
import 'package:reports/widgets/list_card.dart';

// -----------------------------------------------------------------------------
// - StatisticsSettings Widget Implementation
// -----------------------------------------------------------------------------

/// Display the statistics settings card.
class StatisticsSettings extends StatelessWidget {
  const StatisticsSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();

    return AnimatedSize(
      duration: DrawingConstants.animationDuration,
      child: ListCard(
        children: [
          SwitchListTile.adaptive(
            title: Text('settings.statistics.show_statistics').tr(),
            value: prefs.showStatistics,
            onChanged: (value) => prefs.showStatistics = value,
          ),
          if (prefs.showStatistics) ...[
            SwitchListTile.adaptive(
              title: Text('settings.statistics.show_fields').tr(),
              value: prefs.showFieldStatistics,
              onChanged: (value) => prefs.showFieldStatistics = value,
            ),
            SwitchListTile.adaptive(
              title: Text('settings.statistics.show_types').tr(),
              value: prefs.showFieldTypeStatistics,
              onChanged: (value) => prefs.showFieldTypeStatistics = value,
            ),
            SwitchListTile.adaptive(
              title: Text('settings.statistics.show_rules').tr(),
              value: prefs.showCustomRuleStatistitcs,
              onChanged: (value) => prefs.showCustomRuleStatistitcs = value,
            ),
            ListTile(
              title: Text('settings.statistics.custom_rules').tr(),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _CustomStatsRulesView(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _CustomStatsRulesView Widget Implementation
// -----------------------------------------------------------------------------
class _CustomStatsRulesView extends StatefulWidget {
  const _CustomStatsRulesView({Key? key}) : super(key: key);

  @override
  State<_CustomStatsRulesView> createState() => _CustomStatsRulesViewState();
}

class _CustomStatsRulesViewState extends State<_CustomStatsRulesView> {
  void _addRuleCallback(BuildContext context) {
    setState(() => Rule().write(context));
  }

  @override
  Widget build(BuildContext context) {
    final rules = getStatsRules(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.statistics.custom_rules').tr(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addRuleCallback(context),
      ),
      body: ListView(
        children: rules
            .map((rule) => _RuleCard(
                  key: UniqueKey(),
                  rule: rule,
                  setState: setState,
                ))
            .toList(),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// - _RuleCard Widget Implementation
// -----------------------------------------------------------------------------
class _RuleCard extends StatefulWidget {
  _RuleCard({Key? key, required this.rule, required this.setState})
      : super(key: key);

  final Rule rule;
  final setState;

  @override
  State<_RuleCard> createState() => _RuleCardState();
}

class _RuleCardState extends State<_RuleCard> {
  final _formKey = GlobalKey<FormState>();
  bool _modified = false;

  String? _notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'form.not_empty'.tr();
    }
    return null;
  }

  String? _numberValidator(String? value) {
    final exists = _notEmptyValidator(value);

    if (exists != null) {
      return exists;
    }

    if (double.tryParse(value!) == null) {
      return 'form.not_number'.tr();
    }

    return null;
  }

  String? _lessThanValidator(String? value, {String? other}) {
    final exists = _notEmptyValidator(value);

    if (exists != null) {
      return exists;
    }

    final isNumber = _numberValidator(value);
    if (isNumber != null) {
      return isNumber;
    }

    final otherExists = _notEmptyValidator(other);

    if (otherExists != null) {
      return otherExists;
    }

    final valueNum = double.tryParse(value!)!;
    final otherNum = double.tryParse(other!)!;

    if (valueNum < otherNum) {
      return 'form.less_than'.tr();
    }

    return null;
  }

  void _submitCallback(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.rule.write(context);
      setState(() => _modified = false);
    }
  }

  void _removeCallback(BuildContext context) {
    widget.setState(() => widget.rule.remove(context));
  }

  void _setThresholdCallback(String value,
      {int index = 0, bool isRange = false}) {
    if (isRange) {
      widget.rule.threshold[index] = double.tryParse(value);
    } else {
      widget.rule.threshold = double.tryParse(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isRange = widget.rule.operation == 'ran';
    return Card(
      margin: const EdgeInsets.all(DrawingConstants.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'keywords.capitalized.rule',
                      style: DrawingConstants.boldTextStyle,
                    ).tr(),
                  ),
                  FittedBox(
                    child: Row(
                      children: [
                        AnimatedOpacity(
                          duration: DrawingConstants.animationDuration,
                          opacity: _modified ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: !_modified,
                            child: IconButton(
                              icon: Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () => _submitCallback(context),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _removeCallback(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'keywords.capitalized.name'.tr(),
                  filled: true,
                  helperText: '',
                ),
                initialValue: widget.rule.name,
                validator: _notEmptyValidator,
                onChanged: (value) => setState(() {
                  widget.rule.name = value;
                  _modified = true;
                }),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      items: Rule.supportedFields
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(prettyFieldType(e)),
                              value: e,
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        widget.rule.fieldType = value;
                        _modified = true;
                      }),
                      value: widget.rule.fieldType,
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.field'.tr(),
                        filled: true,
                        helperText: '',
                      ),
                      validator: _notEmptyValidator,
                    ),
                  ),
                  SizedBox(
                    width: DrawingConstants.smallPadding,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: DropdownButtonFormField<String>(
                      items: Rule.operations.entries
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(e.value.tr()),
                              value: e.key,
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() {
                        widget.rule.operation = value;
                        if (value == 'ran') {
                          widget.rule.threshold = <double?>[null, null];
                        } else {
                          widget.rule.threshold = null;
                        }
                        _modified = true;
                      }),
                      value: widget.rule.operation,
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.operation'.tr(),
                        filled: true,
                        helperText: '',
                      ),
                      validator: _notEmptyValidator,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: DrawingConstants.smallPadding,
              ),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: (isRange
                                ? 'keywords.capitalized.lower'
                                : 'keywords.capitalized.value')
                            .tr(),
                        filled: true,
                        helperText: '',
                      ),
                      initialValue: isRange
                          ? widget.rule.threshold[0]?.toString()
                          : widget.rule.threshold?.toString(),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: _numberValidator,
                      onChanged: (value) => setState(() {
                        _setThresholdCallback(value, isRange: isRange);
                        _modified = true;
                      }),
                      onSaved: (value) =>
                          _setThresholdCallback(value!, isRange: isRange),
                    ),
                  ),
                  if (isRange) ...[
                    Padding(
                        padding:
                            const EdgeInsets.all(DrawingConstants.smallPadding),
                        child: Text('-')),
                    Flexible(
                      fit: FlexFit.tight,
                      child: Container(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'keywords.capitalized.upper'.tr(),
                            filled: true,
                            helperText: '',
                          ),
                          initialValue: widget.rule.threshold[1]?.toString(),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: (value) => _lessThanValidator(
                            value,
                            other: widget.rule.threshold[0]?.toString(),
                          ),
                          onChanged: (value) => setState(() {
                            _setThresholdCallback(value,
                                index: 1, isRange: true);
                            _modified = true;
                          }),
                          onSaved: (value) => _setThresholdCallback(value!,
                              index: 1, isRange: true),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
