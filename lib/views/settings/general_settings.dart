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
                  onChanged: (value) => prefs.setString(widget.namePref, value),
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
        ),
      ),
    );
  }
}
