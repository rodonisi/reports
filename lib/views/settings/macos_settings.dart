// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/utilities/logger.dart';
import 'package:reports/widgets/list_card.dart';

// -----------------------------------------------------------------------------
// - MacosSettings Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the MacOS specific settings for the app.
class MacosSettings extends StatelessWidget {
  const MacosSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesModel>();
    return ListCard(
      children: [
        ListTile(
          title: const Text('Default Path'),
          subtitle: Text(prefs.defaultPath),
          onTap: () async {
            final dir = await FilePicker.platform.getDirectoryPath();
            logger.d(dir);
            if (dir != null) prefs.defaultPath = dir;
          },
        ),
        SwitchListTile.adaptive(
          title: const Text('Reader Mode'),
          value: prefs.readerMode,
          onChanged: (value) => prefs.readerMode = value,
        ),
      ],
    );
  }
}
