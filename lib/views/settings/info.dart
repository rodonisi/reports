// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reports/common/constants.dart';
import 'package:reports/widgets/loading_indicator.dart';

// -----------------------------------------------------------------------------
// - Info Widget Implementation
// -----------------------------------------------------------------------------

/// Displays and information tile for the app, also containing all the
/// open-source licenses of the used dependencies.
class Info extends StatelessWidget {
  const Info({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(DrawingConstants.mediumPadding),
      child: Padding(
        padding: const EdgeInsets.all(DrawingConstants.smallPadding),
        child: Column(
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return AboutListTile(
                    applicationIcon: Image.asset(
                      'assets/icon/icon.png',
                      height: 64.0,
                      width: 64.0,
                    ),
                    applicationVersion: 'v' + snapshot.data!.version,
                    applicationLegalese: '© 2021 Simon Rodoni',
                  );
                } else if (snapshot.hasError)
                  return Center(
                    child: Text(snapshot.error!.toString()),
                  );

                return const LoadingIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
