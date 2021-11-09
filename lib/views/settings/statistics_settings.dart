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
// -
// -----------------------------------------------------------------------------
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
                  rule: rule,
                  setState: setState,
                ))
            .toList(),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
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
                          child: IconButton(
                            icon: Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                            onPressed: () => _submitCallback(context),
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
                ),
                initialValue: widget.rule.name,
                validator: _notEmptyValidator,
                onChanged: (_) => setState(() => _modified = true),
                onSaved: (value) => widget.rule.name = value!,
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
                      onChanged: (_) => setState(() => _modified = true),
                      value: widget.rule.fieldType,
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.field'.tr(),
                        filled: true,
                      ),
                      validator: _notEmptyValidator,
                      onSaved: (value) => widget.rule.fieldType = value!,
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
                              child: Text(e.value),
                              value: e.key,
                            ),
                          )
                          .toList(),
                      onChanged: (_) => setState(() => _modified = true),
                      value: widget.rule.operation,
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.operation'.tr(),
                        filled: true,
                      ),
                      validator: _notEmptyValidator,
                      onSaved: (value) => widget.rule.operation = value!,
                    ),
                  ),
                  SizedBox(
                    width: DrawingConstants.smallPadding,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.value'.tr(),
                        filled: true,
                      ),
                      initialValue: widget.rule.threshold?.toString(),
                      keyboardType: TextInputType.number,
                      validator: _numberValidator,
                      onChanged: (_) => setState(() => _modified = true),
                      onSaved: (value) =>
                          widget.rule.threshold = double.tryParse(value!),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
