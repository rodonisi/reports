// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/models/preferences_model.dart';
import 'package:reports/widgets/container_tile.dart';
import 'package:reports/utilities/dropbox_utils.dart';
import 'package:reports/utilities/logger.dart';
import 'package:reports/views/settings.dart';
import 'package:reports/widgets/loading_indicator.dart';

// -----------------------------------------------------------------------------
// - DropboxChooser Widget Implementation
// -----------------------------------------------------------------------------
/// DropboxChosser view's arguments.
class DropboxChooserArgs {
  const DropboxChooserArgs({this.name = 'Dropbox', this.path = ''});
  final String name;
  final String path;
}

/// Shows a navigable list of files and directories at the given Dropbox path.
class DropboxChooser extends StatefulWidget {
  static const String routeName = 'dropbox_chooser';

  DropboxChooser({Key? key, required DropboxChooserArgs args})
      : name = args.name,
        path = args.path,
        super(key: key);

  final String name;
  final String path;

  @override
  _DropboxChooserState createState() => _DropboxChooserState();
}

class _DropboxChooserState extends State<DropboxChooser> {
  late Future<dynamic> _listFuture;

  void _selectPathCallback() async {
    final prefs = context.read<PreferencesModel>();
    prefs.dropboxPath = widget.path;

    logger.d('New dropbox path: ${widget.path}');

    Navigator.popUntil(context, ModalRoute.withName(Settings.routeName));

    dbBackupEverything(context);
  }

  @override
  void initState() {
    super.initState();
    _listFuture = dbListFolder(context, widget.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            onPressed: _selectPathCallback,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _listFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Get list data.
            final list = snapshot.data! as List<dynamic>;
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final name = item['name'];
                // Directories do not have a filesize.
                final isFile = item['filesize'] != null;
                final itemPath = item['pathLower'];
                return ContainerTile(
                  title: Text(name),
                  leading: Icon(isFile ? Icons.text_snippet : Icons.folder),
                  trailing:
                      isFile ? null : Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return DropboxChooser(
                            args:
                                DropboxChooserArgs(name: name, path: itemPath));
                      },
                    ),
                  ),
                  enabled: !isFile,
                );
              },
            );
          }

          if (snapshot.hasError)
            return Center(
              child: Text(snapshot.error.toString()),
            );

          return const LoadingIndicator();
        },
      ),
    );
  }
}
