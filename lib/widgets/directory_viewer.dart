// -----------------------------------------------------------------------------
// - Imports
// -----------------------------------------------------------------------------
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/utilities/io_utils.dart';
import 'package:reports/widgets/container_tile.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - DirectoryViewer Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a content of a directory as a list.
class DirectoryViewer extends StatefulWidget {
  DirectoryViewer({
    Key? key,
    this.ignoreDirectories = false,
    required this.fileAction,
    required this.directoryAction,
    required String directoryPath,
  })  : directory = Directory(directoryPath),
        super(key: key);
  final bool ignoreDirectories;
  final void Function(File item) fileAction;
  final void Function(Directory item) directoryAction;
  final Directory directory;

  @override
  _DirectoryViewerState createState() => _DirectoryViewerState();
}

class _DirectoryViewerState extends State<DirectoryViewer> {
  Widget _getTile(FileSystemEntity item) {
    final isFile = item is File;
    final extension = getFileExtension(item.path);
    final IconData tileIcon;
    if (isFile) {
      switch (extension) {
        case ReportsExtensions.layout:
          tileIcon = ReportsIcons.layout;
          break;
        case ReportsExtensions.report:
          tileIcon = ReportsIcons.report;
          break;
        default:
          tileIcon = Icons.description;
      }
    } else {
      tileIcon = Icons.folder;
    }

    return Slidable(
      key: ObjectKey(item),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            icon: Icons.adaptive.share,
            backgroundColor: Colors.blue,
            onPressed: (_) => Share.shareFiles([item.path]),
          ),
          SlidableAction(
            icon: Icons.delete,
            backgroundColor: Colors.red,
            onPressed: (_) {
              setState(() => item.deleteSync(recursive: true));
            },
          ),
        ],
      ),
      // actionPane: const SlidableDrawerActionPane(),
      // secondaryActions: [
      //   IconSlideAction(
      //     icon: Icons.adaptive.share,
      //     color: Colors.blue,
      //     onTap: () => Share.shareFiles([item.path]),
      //   ),
      //   IconSlideAction(
      //     icon: Icons.delete,
      //     color: Colors.red,
      //     onTap: () {
      //       setState(() => item.deleteSync(recursive: true));
      //     },
      //   )
      // ],
      child: ContainerTile(
        title: Text(getFileNameWithoutExtension(item.path)),
        leading: Icon(tileIcon),
        trailing:
            isFile ? null : const Icon(Icons.keyboard_arrow_right_rounded),
        onTap: isFile
            ? () => widget.fileAction(item as File)
            : () => widget.directoryAction(item as Directory),
      ),
    );
  }

  Widget _getList(List<FileSystemEntity> list) {
    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final item = list[i];
        return _getTile(item);
      },
      separatorBuilder: (context, i) =>
          Divider(height: DrawingConstants.dividerHeight),
    );
  }

  List<FileSystemEntity> _getProcessList() {
    final list = widget.directory.listSync();
    if (widget.ignoreDirectories)
      list.removeWhere((element) => element is Directory);

    // Hide system files.
    list.removeWhere((element) => getFileName(element.path).startsWith('.'));

    // Sort list by paths
    list.sort(fileSystemEntityComparator);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // Watch the directory on macos to get live updates of the directory when
    // files are changed.
    if (Platform.isMacOS) {
      return StreamBuilder(
          stream: widget.directory.watch(recursive: true),
          builder: (context, snapshot) {
            return _getList(_getProcessList());
          });
    }

    return _getList(_getProcessList());
  }
}
