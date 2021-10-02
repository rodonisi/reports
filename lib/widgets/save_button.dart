// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:reports/common/constants.dart';

// -----------------------------------------------------------------------------
// - SaveButton Widget Implementation
// -----------------------------------------------------------------------------
class SaveButton extends StatelessWidget {
  const SaveButton({Key? key, required this.onPressed}) : super(key: key);

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DrawingConstants.mediumPadding,
          vertical: DrawingConstants.smallPadding),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          '@.capitalize:keywords.save',
          style: TextStyle(
              color: Theme.of(context).primaryTextTheme.bodyText1?.color),
        ).tr(),
      ),
    );
  }
}
