import 'package:flutter/material.dart';

/// Creates a ListTile contained in a Container with customizable background
/// color.
class ContainerTile extends StatelessWidget {
  const ContainerTile({
    Key? key,
    this.color,
    this.title,
    this.subtitle,
    this.trailing,
    this.leading,
  }) : super(key: key);

  final Color? color;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Theme.of(context).cardColor,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        leading: leading,
      ),
    );
  }
}
