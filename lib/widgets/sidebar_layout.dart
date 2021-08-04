import 'package:flutter/material.dart';

// Displays a side bar layout.
class SideBarLayout extends StatelessWidget {
  const SideBarLayout({Key? key, required this.sidebar, required this.body})
      : super(key: key);

  final Widget sidebar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 300, minWidth: 100),
          child: sidebar,
        ),
        Flexible(
          child: body,
        ),
      ],
    );
  }
}
