import 'package:flutter/material.dart';

class SideBarLayout extends StatelessWidget {
  const SideBarLayout({
    Key? key,
    required this.sidebar,
    required this.body,
  }) : super(key: key);

  final Widget sidebar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [sidebar, Expanded(child: body)],
    );
  }
}
