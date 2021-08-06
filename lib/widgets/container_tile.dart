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
    this.onTap,
    this.enabled = true,
    this.selected = false,
  }) : super(key: key);

  final Color? color;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final void Function()? onTap;
  final bool enabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Colors.transparent,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        leading: leading,
        onTap: onTap,
        enabled: enabled,
        selected: selected,
      ),
    );
  }
}
