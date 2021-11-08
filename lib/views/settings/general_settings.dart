// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/common/rule_structures.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/utilities/print_utils.dart';
import 'package:reports/widgets/controlled_text_field.dart';
import 'package:reports/widgets/list_card.dart';

// -----------------------------------------------------------------------------
// - GeneralSettings Widget Implementation
// -----------------------------------------------------------------------------

/// Diplays the general settings of the app.
class GeneralSettings extends StatelessWidget {
  GeneralSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferencesModel>();

    return ListCard(
      children: [
        ListTile(
          title: Text('settings.general.layout_naming').tr(),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => showBarModalBottomSheet(
            context: context,
            builder: (context) => _DefaultNamingView(
              title: 'settings.general.layout_naming'.tr(),
              namePref: PreferenceKeys.reportBaseName,
              defaultName: prefs.layoutBaseName,
              datePref: PreferenceKeys.reportNameDate,
              timePref: PreferenceKeys.reportNameTime,
            ),
          ),
        ),
        ListTile(
          title: Text('settings.general.report_naming').tr(),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => showBarModalBottomSheet(
            context: context,
            builder: (context) => _DefaultNamingView(
              title: 'settings.general.report_naming'.tr(),
              namePref: PreferenceKeys.layoutBaseName,
              defaultName: prefs.reportBaseName,
              datePref: PreferenceKeys.layoutNameDate,
              timePref: PreferenceKeys.layoutNameTime,
            ),
          ),
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
        )
      ],
    );
  }
}

class _DefaultNamingView extends StatefulWidget {
  _DefaultNamingView({
    Key? key,
    required this.title,
    required this.namePref,
    required this.defaultName,
    required this.datePref,
    required this.timePref,
  }) : super(key: key);

  final String title;
  final String namePref;
  final String defaultName;
  final String datePref;
  final String timePref;

  @override
  __DefaultNamingViewState createState() => __DefaultNamingViewState();
}

class __DefaultNamingViewState extends State<_DefaultNamingView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();

    return SafeArea(
      bottom: true,
      child: AnimatedSize(
          duration: Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: DrawingConstants.smallPadding),
                child: ListTile(
                  title: Text('settings.general.name').tr(),
                  subtitle: ControlledTextField(
                    initialValue: prefs.getString(
                      widget.namePref,
                      defaultValue: widget.defaultName,
                      ensureInitialized: true,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: DrawingConstants.smallPadding,
                      ),
                    ),
                    onChanged: (value) =>
                        prefs.setString(widget.namePref, value),
                    maxLines: 1,
                  ),
                ),
              ),
              SwitchListTile.adaptive(
                title: Text('settings.general.include_date').tr(),
                value: prefs.getBool(widget.datePref),
                onChanged: (value) => prefs.setBool(widget.datePref, value),
              ),
              SwitchListTile.adaptive(
                title: Text('settings.general.include_time').tr(),
                value: prefs.getBool(widget.timePref),
                onChanged: (value) => prefs.setBool(widget.timePref, value),
              ),
              ListTile(
                title: Text('settings.general.preview').tr(),
                subtitle: Text(
                  PreferencesModel.constructName(
                    prefs.getString(widget.namePref),
                    prefs.getBool(widget.datePref),
                    prefs.getBool(widget.timePref),
                  ),
                ),
              ),
              // Add a spacer when the keyboard is shown
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom,
              ),
            ],
          )),
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

class _RuleCard extends StatelessWidget {
  _RuleCard({Key? key, required this.rule, required this.setState})
      : super(key: key);

  final Rule rule;
  final setState;

  final _formKey = GlobalKey<FormState>();

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
      rule.write(context);
    }
  }

  void _removeCallback(BuildContext context) {
    setState(() => rule.remove(context));
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
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => _submitCallback(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_forever),
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
                initialValue: rule.name,
                validator: _notEmptyValidator,
                onSaved: (value) => rule.name = value!,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      items: Rule.supportedFields
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(prettyFieldType(e)),
                              value: e,
                            ),
                          )
                          .toList(),
                      onChanged: (value) {},
                      value: rule.fieldType,
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.field'.tr(),
                        filled: true,
                      ),
                      validator: _notEmptyValidator,
                      onSaved: (value) => rule.fieldType = value!,
                    ),
                  ),
                  SizedBox(
                    width: DrawingConstants.smallPadding,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      items: Rule.operations.entries
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text(e.value).tr(),
                              value: e.key,
                            ),
                          )
                          .toList(),
                      onChanged: (value) {},
                      value: rule.operation,
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.operation'.tr(),
                        filled: true,
                      ),
                      validator: _notEmptyValidator,
                      onSaved: (value) => rule.operation = value!,
                    ),
                  ),
                  SizedBox(
                    width: DrawingConstants.smallPadding,
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'keywords.capitalized.value'.tr(),
                        filled: true,
                      ),
                      initialValue: rule.threshold?.toString(),
                      keyboardType: TextInputType.number,
                      validator: _numberValidator,
                      onSaved: (value) =>
                          rule.threshold = double.tryParse(value!),
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
