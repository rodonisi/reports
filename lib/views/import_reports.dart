// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reports/common/report_structures.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/views/menu_drawer.dart';
import 'package:reports/widgets/container_tile.dart';
import 'package:reports/widgets/directory_viewer.dart';
import 'package:provider/provider.dart';
import 'package:reports/widgets/sidebar_layout.dart';
import 'package:reports/widgets/wrap_navigator.dart';

// -----------------------------------------------------------------------------
// - ImportView Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the selected legal files (illegal files are ignored) and import
/// options when importing reports.
class ImportView extends StatefulWidget {
  static const ValueKey valueKey = ValueKey('ImportView');

  ImportView({Key? key}) : super(key: key);

  @override
  _ImportViewState createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> {
  bool _importAsLayouts = false;
  String _destination = '';
  String? _chooserPath;
  String _reportsDirectory = '';
  List<PlatformFile> _reports = [];
  List<PlatformFile> _layouts = [];
  late AppLocalizations _localizations;

  void _setDestinationCallback() {
    setState(() {
      _destination = _chooserPath ?? '';
      _chooserPath = null;
    });
  }

  void _setChooserPathCallback(String? path) {
    setState(() {
      _chooserPath = path;
    });
  }

  String _getRelativePathCallback(String path) {
    return p.relative(path, from: _reportsDirectory);
  }

  void _showSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
      ),
      backgroundColor: color,
    ));
  }

  void _saveCallback() {
    if (_reports.isEmpty && _layouts.isEmpty) {
      _showSnackBar('No files selected!');
      return;
    }
    // Get destination directory.
    String destinationDirectory = _importAsLayouts
        ? context.read<PreferencesModel>().layoutsPath
        : _destination;
    var hadError = false;

    // Iterate over reports.
    _reports.forEach((element) {
      final destination = p.join(destinationDirectory, element.name);
      final didCopy = copyFile(element.path!, destination);
      // Set the error bool if the copy failed.
      hadError = !didCopy;
    });

    // Iterate over layouts.
    _layouts.forEach((element) {
      final destination =
          p.join(context.read<PreferencesModel>().layoutsPath, element.name);
      final didCopy = copyFile(element.path!, destination);
      // Set the error if the copy failed.
      hadError = !didCopy;
    });

    if (hadError)
      // Show failure snackbar.
      _showSnackBar('Failed to import some files.');
    else
      // Show success snackbar.
      _showSnackBar('Succesfully imported files!', color: Colors.green);

    setState(() {
      // Clear import lists.
      _reports.clear();
      _layouts.clear();
    });
  }

  AppBar _getAppBar() {
    return AppBar(
      title: Text(_localizations.importReports),
    );
  }

  Widget _getBottomBar() {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ElevatedButton(
          child: Text('Import'),
          onPressed: _saveCallback,
        ),
      ),
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
      final paths = getSubPaths(_getRelativePathCallback(_chooserPath!));
      paths.forEach((element) {
        final fullPath =
            p.join(_reportsDirectory, element == '.' ? '' : element);
        pagesList.add(
          MaterialPage(
            name: fullPath,
            child: _DestinationChooser(
              path: fullPath,
              onSelected: _setDestinationCallback,
              setPath: _setChooserPathCallback,
            ),
          ),
        );
      });
    }

    return WrapNavigator(
      child: MaterialPage(
        child: Scaffold(
          appBar: _getAppBar(),
          drawer: context.findAncestorWidgetOfExactType<SideBarLayout>() == null
              ? MenuDrawer()
              : null,
          body: _ImportViewBody(
            destination: _destination,
            reports: _reports,
            layouts: _layouts,
            getImportAsLayouts: () => _importAsLayouts,
            setImportAsLayoutsCallback: (bool value) =>
                _importAsLayouts = value,
            openChooserCallback: () => _setChooserPathCallback(_destination),
          ),
          bottomNavigationBar: _getBottomBar(),
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

class _ImportViewBody extends StatefulWidget {
  _ImportViewBody({
    Key? key,
    required this.destination,
    required this.reports,
    required this.layouts,
    required this.getImportAsLayouts,
    required this.setImportAsLayoutsCallback,
    required this.openChooserCallback,
  }) : super(key: key);

  final bool Function() getImportAsLayouts;
  final void Function(bool value) setImportAsLayoutsCallback;
  final String destination;
  final void Function() openChooserCallback;
  final List<PlatformFile> reports;
  final List<PlatformFile> layouts;

  @override
  __ImportViewBodyState createState() => __ImportViewBodyState();
}

class __ImportViewBodyState extends State<_ImportViewBody> {
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _getReportsOptions() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Text(
          'Reports Options',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      ContainerTile(
        title: Text(_localizations.destination),
        subtitle: Text(
          p.relative(widget.destination,
              from: context.read<PreferencesModel>().reportsPath),
        ),
        enabled: !widget.getImportAsLayouts(),
        onTap: widget.openChooserCallback,
      ),
      SwitchListTile.adaptive(
        value: widget.getImportAsLayouts(),
        title: Text(_localizations.importAsLayout),
        onChanged: (value) =>
            setState(() => widget.setImportAsLayoutsCallback(value)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _GridView(
                files: widget.reports,
                layouts: widget.layouts,
                setState: setState,
              ),
            ),
          ),
          if (widget.reports.isNotEmpty) ..._getReportsOptions(),
        ],
      ),
    );
  }
}

extension _ReportsUtils on PlatformFile {
  bool? get isReport {
    if (path != null) {
      final jsonString = File(path!).readAsStringSync();
      final jsonMap = jsonDecode(jsonString);
      if (jsonMap[FileHeader.typeID] == FileHeader.reportID) {
        return true;
      } else if (jsonMap[FileHeader.typeID] == FileHeader.layoutID) {
        return false;
      }
    }

    return null;
  }
}

class _GridView extends StatelessWidget {
  const _GridView(
      {Key? key,
      required this.files,
      required this.layouts,
      required this.setState})
      : super(key: key);

  final List<PlatformFile> files;
  final List<PlatformFile> layouts;
  final void Function(void Function()) setState;

  void _processFiles(FilePickerResult pickedFiles) {
    pickedFiles.files.removeWhere((element) => element.isReport == null);
    pickedFiles.files.forEach((element) {
      if (element.isReport!)
        files.add(element);
      else
        layouts.add(element);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty && layouts.isEmpty)
      return Center(
        child: TextButton(
          child: Text('Select Files'),
          onPressed: () {
            FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: ['.json']).then((pickedFiles) {
              if (pickedFiles != null) {
                _processFiles(pickedFiles);
              }
            });
          },
        ),
      );

    return GridView.count(
      crossAxisCount: 3,
      children: [
        ...files.map<Widget>((item) {
          return _ImportGridItem(
            icon: const Icon(ReportsIcons.report),
            item: item,
            onDelete: () => setState(() => files.remove(item)),
          );
        }).toList(),
        ...layouts.map<Widget>((item) {
          return _ImportGridItem(
            icon: const Icon(ReportsIcons.layout),
            item: item,
            onDelete: () => setState(() => layouts.remove(item)),
          );
        }).toList()
      ],
    );
  }
}

class _ImportGridItem extends StatelessWidget {
  const _ImportGridItem({
    Key? key,
    required this.icon,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  final Widget icon;
  final PlatformFile item;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: icon,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      item.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.cancel,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
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
