// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reports/common/constants.dart';
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
import 'package:reports/extensions/preferences_model_extensions.dart';

// -----------------------------------------------------------------------------
// - ImportView Widget Implementation
// -----------------------------------------------------------------------------

/// Displays the selected legal files (illegal files are ignored) and import
/// options when importing reports.
class ImportView extends StatefulWidget {
  static const ValueKey valueKey = ValueKey('ImportView');

  const ImportView({Key? key}) : super(key: key);

  @override
  State<ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<ImportView> {
  bool _importAsLayouts = false;
  String _destination = '';
  String? _chooserPath;
  String _reportsDirectory = '';
  final List<PlatformFile> _reports = [];
  final List<PlatformFile> _layouts = [];

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

  void _saveCallback() async {
    if (_reports.isEmpty && _layouts.isEmpty) {
      _showSnackBar('import.no_files'.tr());
      return;
    }
    // Get destination directory.
    String destinationDirectory = _importAsLayouts
        ? context.read<PreferencesModel>().layoutsPath
        : _destination;
    var hadError = false;

    // Iterate over reports.
    for (var element in _reports) {
      bool didCopy = true;
      if (_importAsLayouts) {
        // Extract the layout from the report file.
        final file = File(element.path!);
        final jsonString = file.readAsStringSync();
        final report = Report.fromJSON(jsonString);
        final layoutJSON = report.layout.toJSON();

        // Write the extracted layout.
        didCopy = await writeToFile(
          layoutJSON,
          joinAndSetExtension(
            destinationDirectory,
            report.layout.name,
            extension: ReportsExtensions.layout,
          ),
        );
      } else {
        final destination = p.join(destinationDirectory, element.name);
        didCopy = copyFile(element.path!, destination);
      }
      // Set the error bool if the copy failed.
      hadError = !didCopy;
    }

    if (!mounted) return;

    // Iterate over layouts.
    for (var element in _layouts) {
      final destination =
          p.join(context.read<PreferencesModel>().layoutsPath, element.name);
      final didCopy = copyFile(element.path!, destination);
      // Set the error if the copy failed.
      hadError = !didCopy;
    }

    if (hadError) {
      _showSnackBar('import.error'.tr());
    } else {
      _showSnackBar('import.success'.tr(), color: Colors.green);
    }

    setState(() {
      // Clear import lists.
      _reports.clear();
      _layouts.clear();
    });
  }

  AppBar _getAppBar() {
    return AppBar(
      title: const Text('import.title').tr(),
    );
  }

  Widget _getBottomBar() {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DrawingConstants.smallPadding,
          horizontal: DrawingConstants.mediumPadding,
        ),
        child: ElevatedButton(
          onPressed: _saveCallback,
          child: const Text('import.import_button').tr(),
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
    final pagesList = <MaterialPage>[];
    if (_chooserPath != null) {
      final paths = getSubPaths(_getRelativePathCallback(_chooserPath!));
      for (var element in paths) {
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
      }
    }

    return WrapNavigator(
      child: MaterialPage(
        child: Scaffold(
          appBar: _getAppBar(),
          drawer: context.findAncestorWidgetOfExactType<SideBarLayout>() == null
              ? const MenuDrawer()
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
  const _ImportViewBody({
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
  List<Widget> _getReportsOptions() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: const Text(
          'import.reports_options',
          style: TextStyle(fontWeight: FontWeight.bold),
        ).tr(),
      ),
      ContainerTile(
        title: const Text('import.destination').tr(),
        subtitle: Text(
          p.relative(widget.destination,
              from: context.read<PreferencesModel>().reportsPath),
        ),
        enabled: !widget.getImportAsLayouts(),
        onTap: widget.openChooserCallback,
      ),
      SwitchListTile.adaptive(
        value: widget.getImportAsLayouts(),
        title: const Text('import.as_layout').tr(),
        onChanged: (value) =>
            setState(() => widget.setImportAsLayoutsCallback(value)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DrawingConstants.smallPadding),
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

enum _FileType { report, layout, other }

extension _ReportsUtils on PlatformFile {
  _FileType get fileType {
    if (path != null) {
      final extension = getFileExtension(path!);
      if (extension == ReportsExtensions.report) {
        return _FileType.report;
      } else if (extension == ReportsExtensions.layout) {
        return _FileType.layout;
      }
    }

    return _FileType.other;
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
    for (var picked in pickedFiles.files) {
      if (picked.fileType == _FileType.report &&
          files.indexWhere((element) => picked.path == element.path) < 0) {
        files.add(picked);
      } else if (picked.fileType == _FileType.layout &&
          layouts.indexWhere((element) => picked.path == element.path) < 0) {
        layouts.add(picked);
      }
    }
    setState(() {});
  }

  void _pickFilesCallback() {
    FilePicker.platform
        .pickFiles(
      allowMultiple: true,
      // Cannot filter for custom types, so we have to allow all types and just
      // filter them out later.
      type: FileType.any,
    )
        .then((pickedFiles) {
      if (pickedFiles != null) {
        _processFiles(pickedFiles);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
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
      }).toList(),
      _PickFilesItem(onTap: _pickFilesCallback)
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150.0,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return items[index];
      },
    );
  }
}

class _PickFilesItem extends StatelessWidget {
  const _PickFilesItem({Key? key, required this.onTap}) : super(key: key);

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DrawingConstants.verySmallPadding),
      child: ElevatedButton(
        onPressed: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(child: FittedBox(child: Icon(Icons.add))),
            Flexible(child: const Text('import.pick').tr()),
          ],
        ),
      ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: DrawingConstants.smallPadding),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(p.basename(path)),
        actions: [
          TextButton(
            onPressed: onSelected,
            child: const Text('import.select').tr(),
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
