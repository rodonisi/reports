// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/widgets/list_card.dart';

// -----------------------------------------------------------------------------
// - AppearanceSettings Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the appearance settings for the app.
class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListCard(
      children: [
        ListTile(
          title: const Text('Appearance'),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => showBarModalBottomSheet(
            context: context,
            builder: (context) => _AppearanceSelectionView(),
          ),
        ),
        ListTile(
            title: const Text('Accent Color'),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () => showBarModalBottomSheet(
                  context: context,
                  builder: (context) => _ColorSelectionView(),
                )),
      ],
    );
  }
}

class _AppearanceSelectionView extends StatelessWidget {
  const _AppearanceSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile<ThemeMode>(
          title: Text('Light'),
          value: ThemeMode.light,
          groupValue: prefs.themeMode,
          onChanged: (value) => prefs.themeMode = value!,
        ),
        RadioListTile<ThemeMode>(
          title: Text('Dark'),
          value: ThemeMode.dark,
          groupValue: prefs.themeMode,
          onChanged: (value) => prefs.themeMode = value!,
        ),
        RadioListTile<ThemeMode>(
          title: Text('System'),
          value: ThemeMode.system,
          groupValue: prefs.themeMode,
          onChanged: (value) => prefs.themeMode = value!,
        )
      ],
    );
  }
}

class _ColorSelectionView extends StatelessWidget {
  const _ColorSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: prefs.colors.length,
      itemBuilder: (context, index) {
        return RadioListTile<int>(
          value: index,
          groupValue: prefs.accentColorValue,
          onChanged: (value) => prefs.accentColorValue = value!,
          title: Text(prefs.colorNames[index]),
          activeColor: prefs.accentColor,
        );
      },
    );
  }
}
