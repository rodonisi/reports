// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/common/io.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/widgets/container_tile.dart';
import 'package:reports/widgets/directory_viewer.dart';

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
  String _reportsDirectory = '';
  bool _initComplete = false;

  Future<void> _onInit() async {
    _destination = await getReportsDirectory;
    _reportsDirectory = _destination;
    setState(() => _initComplete = true);
  }

  void _setDestinationCallback(String newDestination) {
    setState(() {
      _destination = newDestination;
      Navigator.popUntil(context, ModalRoute.withName('ImportLayout'));
    });
  }

  String _getRelativePath(String path) {
    return p.relative(path, from: _reportsDirectory);
  }

  @override
  void initState() {
    super.initState();
    _onInit();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (!_initComplete) Container();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.importReports),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.cancel_rounded,
            color: Colors.red,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await _saveCallback(context);
              },
              icon: Icon(
                Icons.check,
                color: Colors.green,
              ))
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: widget.files.length,
                  itemBuilder: (context, index) =>
                      Text(widget.files[index].name),
                ),
              ),
            ),
          ),
          ContainerTile(
            title: Text(localizations.destination),
            trailing: Text(_getRelativePath(_destination)),
            enabled: !_importAsLayouts,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _DestinationChooser(
                    path: _reportsDirectory,
                    onSelected: _setDestinationCallback,
                    getRelativePath: _getRelativePath,
                  ),
                )),
          ),
          SwitchListTile.adaptive(
            tileColor: Theme.of(context).cardColor,
            value: _importAsLayouts,
            title: Text(localizations.importAsLayout),
            onChanged: (value) => setState(() => _importAsLayouts = value),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCallback(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    // Get destination directory.
    String destination =
        _importAsLayouts ? await getLayoutsDirectory : _destination;

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
}

class _DestinationChooser extends StatelessWidget {
  const _DestinationChooser({
    Key? key,
    required this.path,
    required this.onSelected,
    required this.getRelativePath,
  }) : super(key: key);
  final String path;
  final void Function(String path) onSelected;
  final String Function(String path) getRelativePath;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(getRelativePath(path)),
        actions: [
          TextButton(
            onPressed: () => onSelected(path),
            child: Text(localizations.select),
          ),
        ],
      ),
      body: DirectoryViewer(
          fileAction: (file) {},
          directoryAction: (Directory item) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => _DestinationChooser(
                    path: item.path,
                    onSelected: onSelected,
                    getRelativePath: getRelativePath,
                  ),
                ),
              ),
          directoryPath: path),
    );
  }
}
