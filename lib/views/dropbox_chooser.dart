// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/dropbox_utils.dart';
import 'package:reports/common/preferences.dart';
import 'package:reports/common/logger.dart';
import 'package:reports/views/settings.dart';

// -----------------------------------------------------------------------------
// - DropboxChooser Widget Implementation
// -----------------------------------------------------------------------------
/// DropboxChosser view's arguments.
class DropboxChooserArgs {
  const DropboxChooserArgs(
      {this.name = 'Dropbox', this.path = '', required this.setState});
  final String name;
  final String path;
  final setState;
}

/// Shows a navigable list of files and directories at the given Dropbox path.
class DropboxChooser extends StatefulWidget {
  static const String routeName = 'dropbox_chooser';

  DropboxChooser({Key? key, required DropboxChooserArgs args})
      : name = args.name,
        path = args.path,
        setState = args.setState,
        super(key: key);

  final String name;
  final String path;
  final setState;

  @override
  _DropboxChooserState createState() => _DropboxChooserState();
}

class _DropboxChooserState extends State<DropboxChooser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(Preferences.dropboxPath, widget.path);

                logger.d('New dropbox path: ${widget.path}');

                widget.setState(() {});
                Navigator.popUntil(
                    context, ModalRoute.withName(Settings.routeName));

                dbBackupEverything();
              },
              icon: Icon(Icons.check)),
        ],
      ),
      body: FutureBuilder(
        future: dbListFolder(widget.path),
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
                return ListTile(
                  title: Text(name),
                  leading: Icon(isFile ? Icons.text_snippet : Icons.folder),
                  trailing:
                      isFile ? null : Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => Navigator.pushNamed(
                      context, DropboxChooser.routeName,
                      arguments: DropboxChooserArgs(
                          name: name,
                          path: itemPath,
                          setState: widget.setState)),
                  enabled: !isFile,
                );
              },
            );
          }

          if (snapshot.hasError)
            return Center(
              child: Text(snapshot.error.toString()),
            );

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text('Loading'),
              ],
            ),
          );
        },
      ),
    );
  }
}
