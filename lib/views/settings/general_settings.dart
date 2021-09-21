// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';
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
    final localizations = AppLocalizations.of(context)!;

    return ListCard(
      children: [
        ListTile(
          title: Text(localizations.defaultReportNaming),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => showBarModalBottomSheet(
            context: context,
            builder: (context) => _DefaultNamingView(
              title: localizations.defaultReportNaming,
              namePref: PreferenceKeys.reportBaseName,
              datePref: PreferenceKeys.reportNameDate,
              timePref: PreferenceKeys.reportNameTime,
            ),
          ),
        ),
        ListTile(
          title: Text(localizations.defaultLayoutNaming),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => showBarModalBottomSheet(
            context: context,
            builder: (context) => _DefaultNamingView(
              title: localizations.defaultLayoutNaming,
              namePref: PreferenceKeys.layoutBaseName,
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
    required this.datePref,
    required this.timePref,
  }) : super(key: key);

  final String title;
  final String namePref;
  final String datePref;
  final String timePref;

  @override
  __DefaultNamingViewState createState() => __DefaultNamingViewState();
}

class __DefaultNamingViewState extends State<_DefaultNamingView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final prefs = context.watch<PreferencesModel>();

    return AnimatedSize(
      duration: Duration(milliseconds: 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListTile(
              title: Text(localizations.baseName),
              subtitle: ControlledTextField(
                initialValue: prefs.getString(widget.namePref),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                ),
                onChanged: (value) => prefs.setString(widget.namePref, value),
                maxLines: 1,
              ),
            ),
          ),
          SwitchListTile.adaptive(
            title: Text(localizations.includeDate),
            value: prefs.getBool(widget.datePref),
            onChanged: (value) => prefs.setBool(widget.datePref, value),
          ),
          SwitchListTile.adaptive(
            title: Text(localizations.inlcudeTime),
            value: prefs.getBool(widget.timePref),
            onChanged: (value) => prefs.setBool(widget.timePref, value),
          ),
          ListTile(
            title: Text(localizations.preview),
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
    );
  }
}
