// -----------------------------------------------------------------------------
// - Imports
// -----------------------------------------------------------------------------
import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:reports/widgets/container_tile.dart';
import 'package:share_plus/share_plus.dart';

// -----------------------------------------------------------------------------
// - DirectoryViewer Implementation
// -----------------------------------------------------------------------------

/// Displays a content of a directory as a list.
class DirectoryViewer extends StatefulWidget {
  DirectoryViewer({
    Key? key,
    this.fileIcon = Icons.description,
    this.ignoreDirectories = false,
    required this.fileAction,
    required this.directoryAction,
    required String directoryPath,
  })  : directory = Directory(directoryPath),
        super(key: key);
  final IconData fileIcon;
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

    return Slidable(
      key: ObjectKey(item),
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          icon: Icons.adaptive.share,
          color: Colors.blue,
          onTap: () => Share.shareFiles([item.path]),
        ),
        IconSlideAction(
          icon: Icons.delete,
          color: Colors.red,
          onTap: () {
            setState(() => item.deleteSync(recursive: true));
          },
        )
      ],
      child: ContainerTile(
        title: Text(p.basenameWithoutExtension(item.path)),
        leading: Icon(isFile ? widget.fileIcon : Icons.folder),
        trailing: isFile ? null : Icon(Icons.keyboard_arrow_right_rounded),
        onTap: isFile
            ? () => widget.fileAction(item as File)
            : () => widget.directoryAction(item as Directory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.directory.listSync();

    if (widget.ignoreDirectories)
      list.removeWhere((element) => element is Directory);

    list.sort((a, b) => a.path.compareTo(b.path));

    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final item = list[i];
        return _getTile(item);
      },
      separatorBuilder: (context, i) => Divider(height: 0.0),
    );
  }
}
