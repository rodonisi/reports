// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/widgets/container_tile.dart';
import 'package:reports/widgets/directory_viewer.dart';
import 'package:provider/provider.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - ImportReportsView Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the selected legal files (illegal files are ignored) and import
/// options when importing reports.
class ImportReportsView extends StatefulWidget {
  ImportReportsView({Key? key, required this.files}) : super(key: key);
  final List<PlatformFile> files;

  @override
  _ImportReportsViewState createState() => _ImportReportsViewState();
}

class _ImportReportsViewState extends State<ImportReportsView> {
  bool _importAsLayouts = false;
  String _destination = '';
  String? _chooserPath;
  String _reportsDirectory = '';
  late AppLocalizations _localizations;

  void _setDestinationCallback() {
    setState(() {
      _destination = _chooserPath ?? '';
      _chooserPath = null;
    });
  }

  void _setChooserPath(String? path) {
    setState(() {
      _chooserPath = path;
    });
  }

  String _getRelativePath(String path) {
    return p.relative(path, from: _reportsDirectory);
  }

  void _saveCallback(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Get destination directory.
    String destination = _importAsLayouts
        ? context.read<PreferencesModel>().layoutsPath
        : _destination;

    // Iterate over files.
    widget.files.forEach((element) {
      // Get file.
      final file = File(element.path!);
      // Get full destination path.
      final path = p.join(destination, element.name);

      // Check if a file already exists at the destination.
      if (File(path).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            localizations.fileExists(localizations.report),
          ),
          backgroundColor: Colors.red,
        ));
        return;
      }

      logger.d('Imported report to path $path');

      // Copy the file to the destination.
      file.copy(path);
    });

    Navigator.pop(context);
  }

  AppBar _getAppBar() {
    return AppBar(
      title: Text(_localizations.importReports),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.close_rounded,
          color: Colors.red,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () async {
              _saveCallback(context);
            },
            icon: Icon(
              Icons.check,
              color: Colors.green,
            ))
      ],
    );
  }

  Widget _getBody() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Card(
            margin: EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: widget.files.length,
                itemBuilder: (context, index) => Text(widget.files[index].name),
              ),
            ),
          ),
        ),
        ContainerTile(
          title: Text(_localizations.destination),
          subtitle: Text(_getRelativePath(_destination)),
          enabled: !_importAsLayouts,
          onTap: () => setState(() => _chooserPath = _destination),
        ),
        SwitchListTile.adaptive(
          value: _importAsLayouts,
          title: Text(_localizations.importAsLayout),
          onChanged: (value) => setState(() => _importAsLayouts = value),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _destination = context.read<PreferencesModel>().reportsPath;
    _reportsDirectory = _destination;
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;

    final pagesList = <MaterialPage>[];
    if (_chooserPath != null) {
      final paths = getSubPaths(_getRelativePath(_chooserPath!));
      paths.forEach((element) {
        final fullPath =
            p.join(_reportsDirectory, element == '.' ? '' : element);
        pagesList.add(
          MaterialPage(
            name: fullPath,
            child: _DestinationChooser(
              path: fullPath,
              onSelected: _setDestinationCallback,
              setPath: _setChooserPath,
            ),
          ),
        );
      });
    }

    return WrapNavigator(
      child: MaterialPage(
        child: Scaffold(
          appBar: _getAppBar(),
          body: _getBody(),
        ),
      ),
      additionalPages: pagesList,
      onPopPage: (route, result) {
        final dir = route.settings.name ?? '';
        setState(() =>
            _chooserPath = dir == _reportsDirectory ? null : p.dirname(dir));

        return route.didPop(result);
      },
    );
  }
}

class _DestinationChooser extends StatelessWidget {
  const _DestinationChooser({
    Key? key,
    required this.path,
    required this.onSelected,
    required this.setPath,
  }) : super(key: key);
  final String path;
  final void Function() onSelected;
  final void Function(String path) setPath;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(path)),
        actions: [
          TextButton(
            onPressed: onSelected,
            child: Text(localizations.select),
          ),
        ],
      ),
      body: DirectoryViewer(
        fileAction: (file) {},
        directoryAction: (Directory item) => setPath(item.path),
        directoryPath: path,
      ),
    );
  }
}
