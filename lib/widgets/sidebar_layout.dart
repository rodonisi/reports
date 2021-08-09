// -----------------------------------------------------------------------------
// - Packages
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// - SideBarLayout Widget Implementation
// -----------------------------------------------------------------------------

/// Displays a side bar layout.
class SideBarLayout extends StatelessWidget {
  const SideBarLayout(
      {Key? key, required this.sidebar, required this.body, this.width})
      : super(key: key);

  final Widget sidebar;
  final Widget body;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (width == null)
          sidebar
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width!),
            child: sidebar,
          ),
        Flexible(
          child: body,
        ),
      ],
    );
  }
}
