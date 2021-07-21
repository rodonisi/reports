// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
// - Local Imports
// -----------------------------------------------------------------------------
import 'package:reports/common/reports_icons_icons.dart';
import 'package:reports/common/io.dart';
import 'package:reports/models/layouts.dart';
import 'package:reports/views/form_builder.dart';
import 'package:reports/views/menu_drawer.dart';

// -----------------------------------------------------------------------------
// - Layouts Widget Implementation
// -----------------------------------------------------------------------------

/// Displays all the layouts stored in the app in a list.
class Layouts extends StatelessWidget {
  const Layouts({Key? key}) : super(key: key);

  static const String routeName = '/layouts';

  @override
  Widget build(BuildContext context) {
    var _layoutsProvider = context.watch<LayoutsModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.layoutsTitle),
      ),
      drawer: MenuDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showCupertinoModalBottomSheet(
          context: context,
          bounce: true,
          closeProgressThreshold: 0.4,
          builder: (context) {
            final args = FormBuilderArgs(name: '');
            return FormBuilder(args: args);
          },
        ),
      ),
      body: _LayoutsList(),
    );
  }
}

// -----------------------------------------------------------------------------
// - _LayoutList Widget Implementation
// -----------------------------------------------------------------------------
class _LayoutsList extends StatelessWidget {
  const _LayoutsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var layoutsProvider = context.watch<LayoutsModel>();
    return ListView.separated(
      itemCount: layoutsProvider.layouts.length,
      itemBuilder: (context, index) {
        final item = layoutsProvider.layouts[index];
        return Slidable(
          key: Key(item),
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: [
            IconSlideAction(
              icon: Icons.delete,
              color: Colors.red,
              onTap: () {
                deleteFile('$layoutsDirectory/$item');
                layoutsProvider.removeAt(index);
              },
            )
          ],
          child: ListTile(
            title: Text(layoutsProvider.layouts[index]),
            leading: Icon(ReportsIcons.layout),
            onTap: () => showCupertinoModalBottomSheet(
              context: context,
              bounce: true,
              closeProgressThreshold: 0.4,
              builder: (context) {
                final args = FormBuilderArgs(
                  name: layoutsProvider.layouts[index],
                  index: index,
                );
                return FormBuilder(args: args);
              },
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(height: 0.0),
    );
  }
}
